% Data max
load('../data/data.mat');
subjectNr = 1;
T = size(Xs,2); % Number of data points
N = size(Xs,3); % Number of variables
data = reshape(Xs(subjectNr,:,:),T,N);
N=6;
data=data(1:N,:);
%structure = reshape(Gs(subjectNr,:,:),N,N);
fprintf('Done loading data.\n');
C = cov(data);
fprintf('Done calculating covariance.\n');



perm1 = 1:N;
perm2 = N:-1:1;
C_perm1 = C(perm1,perm1);
C_perm2 = C(perm2,perm2);
% Find adjacency matrix given time-series data.
alpha = 0.05;
fprintf('calculating structure.\n');
cond_indep = 'cond_indep_fisher_z';
[G_perm1,sepset_perm1] = structure_pc(cond_indep,N,C_perm1,T,alpha);
[G_perm2,sepset_perm2] = structure_pc(cond_indep,N,C_perm2,T,alpha);
fprintf('calculating direction.\n');
PDAG_perm1 = directional_pc(G_perm1,sepset_perm1);
PDAG_perm2 = directional_pc(G_perm2,sepset_perm2);

G1(perm1,perm1) = G_perm1;
G2(perm2,perm2) = G_perm2;
sepset1(perm1,perm1) = sepset_perm1;
sepset2(perm2,perm2) = sepset_perm2;
PDAG1(perm1,perm1) = PDAG_perm1;
PDAG2(perm2,perm2) = PDAG_perm2;
fprintf('finished, showing figures.\n');
figure; imagesc(PDAG1); colormap hot; axis square;
figure; imagesc(PDAG2); colormap hot; axis square;