function [directed_graph] = directional_pc3(undirected_graph, sepset)

N = size(undirected_graph, 1);
assert(N == size(undirected_graph, 2), 'input graph is not a square matrix');
directed_graph = undirected_graph;

[directed_graph, nrEdges] = find_v_structures(undirected_graph, directed_graph, sepset);

dtime = cputime;
fprintf('Calculating paths in graph...');
% (x,y) denotes if there is a path from x to y
path_from_to = double(directed_graph == 2);
path_from_to = find_all_paths(path_from_to);
dtime = cputime - dtime;
fprintf('\t- Execution time : %3.2f seconds\n',dtime);

dtime = cputime;
fprintf('Finding other directed structures...');
% the point x,y to check for both conditions
x = 1;
y = 1;
% used to determine whether a full loop over all elements has been made
% without an update (in that case, the loop can stop)
iterations_without_updates = 0;
while (iterations_without_updates <= N*N)
	% for each undirected adjacent pair (x,y)
	if directed_graph(x,y) == 1 
		% whether an arrow x -> y or y -> x has been found
		x_y_directed = 0;
				
		% rule 1
		for z = mysetdiff(1:N,[x,y])
			if (directed_graph(z,x) == 2 && directed_graph(z,y) == 0 && directed_graph(y,z) == 0)
				x_y_directed = 1;
			end
		end
		
		% rule 2
		if (path_from_to(x,y) && ~x_y_directed)
			x_y_directed = 1;
		end

		if (x_y_directed)
			directed_graph(x,y) = 2;
			directed_graph(y,x) = 0;
			nrEdges = nrEdges + 1;
			path_from_to = find_all_paths(double(directed_graph==2), path_from_to);
			iterations_without_updates = 0;
		end
	end
	iterations_without_updates = iterations_without_updates + 1;
	[x,y] = next_point(x,y,N);
end
dtime = cputime - dtime;
fprintf('\t- Execution time : %3.2f seconds\n',dtime);
fprintf('Done finding additional edges: %d directional edges found.\n', nrEdges);

end

function [x, y] = next_point(x, y, N)
% gives the next point in a square of size N. Returns (x+1,y) if that is in
% the bounds, otherwise skips to next row
if (x < N)
	x = x+1;
else
	x = 1;
	if (y < N)
		y = y+1;
	else
		y = 1;
	end
end
if (x == y)
	[x, y] = next_point(x, y, N);
end
end

% This works because we're adding directions to our adjacency graph,
% instead of removing.
function [path_from_to] = find_all_paths(directed_adjacencies, path_from_to)
% if a previous version of path_from_to is given, that can be used to determine
% the current path_from_to. If no previous version is present, a new version is
% created from scratch (give no parameter path_from_to)
if (nargin < 2)
	path_from_to = directed_adjacencies;
end

path_from_to = path_from_to * directed_adjacencies;
prev_tmp = directed_adjacencies;
tmp = double(logical(prev_tmp + path_from_to));

while(~isequal(tmp, prev_tmp))
	path_from_to = path_from_to * directed_adjacencies;
	prev_tmp = tmp;
	tmp = double(logical(tmp+ path_from_to));
end
path_from_to = tmp;
end


% Given a directed graph, calculates what nodes are connected to what
% others.


% Graph coding
% 0 - not connected
% 1 - neighbour
% 2 - arrow
% 3 - dot
% For example, (x,y)=1 and (y,x)=2 means y -> x