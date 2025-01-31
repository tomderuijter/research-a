function [directed_graph] = directional_modified_pc(undirected_graph, sepset)

N = size(undirected_graph, 1);
assert(N == size(undirected_graph, 2), 'input graph is not a square matrix');
directed_graph = undirected_graph;

% turn undirected edges into bolletjes
directed_graph = directed_graph .* 3;

fprintf('Finding V-structures...');
dtime=cputime;

[directed_graph, nrEdges] = find_v_structures(undirected_graph, directed_graph, sepset);
fprintf('Done finding V-structures: %d directional edges found.\n', nrEdges);
dtime = cputime - dtime;
fprintf('\t- Execution time : %3.2f seconds\n',dtime);

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
	% for each connected pair (x,y)
	if directed_graph(x,y) ~= 0 || directed_graph(y,x) ~= 0
		% whether an arrow x -> y has been found
		x_y_directed = 0;
		
		% rule 1
		for z = mysetdiff(1:N,[x,y])
			if (directed_graph(z,x) == 2 && directed_graph(y,x) ~= 2 && directed_graph(z,y) == 0 && directed_graph(y,z) == 0)
				directed_graph(y,x) = 0;
				% for not counting arrows twice
				if (directed_graph(x,y) ~= 2)
					directed_graph(x,y) = 2;
					x_y_directed = 1;
				end
			end
		end
		
		% rule 2
		if (path_from_to(x,y) && ~x_y_directed)
			if (directed_graph(x,y) ~= 2)
				directed_graph(x,y) = 2;
				x_y_directed = 1;
			end
		end

		if (x_y_directed)
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

% For graphical purposes, convert dots to neighbours.
directed_graph(directed_graph == 3) = 1;

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

function [directed_graph, nrEdges] = find_v_structures(undirected_graph, directed_graph, sepset)
N = size(undirected_graph, 1);
nrEdges=0;
% own v-structure-code
for x = 1 : N
	right_of_diag = ((x+1) : N);
	for y = right_of_diag

		% x and y not connected -> not interesting
		if ~undirected_graph(x,y)
			continue
		end

		% for all elements ,excluding x and y
		% x_alg etc. are x, y and z as described in the algorithm
		for z_alg = 1:N
			if z_alg == x || z_alg == y
				continue;
			end
			if (undirected_graph(x,z_alg) && ~undirected_graph(y,z_alg))
				x_alg = y;
				y_alg = x;
			elseif (undirected_graph(y,z_alg) && ~undirected_graph(x,z_alg))
				x_alg = x;
				y_alg = y;
			else
				continue
			end

			% if y is not in sepset(x,z)
			if (~ismember_cell(y_alg, sepset{x_alg,z_alg}))
				if (directed_graph(x_alg, y_alg) ~= 2)
					directed_graph(x_alg, y_alg) = 2;
					nrEdges = nrEdges + 1;
				end
				if (directed_graph(z_alg, y_alg) ~= 2)
					directed_graph(z_alg, y_alg) = 2;
					nrEdges = nrEdges + 1;
				end
			end
		end
	end
end
end


% Graph coding
% 0 - not connected
% 1 - neighbour
% 2 - arrow
% 3 - dot
% For example, (x,y)=1 and (y,x)=2 means y -> x