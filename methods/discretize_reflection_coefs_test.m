%% test_discretize_reflection_coefs

samples = mvnrnd([0, 0.2, 0.4],diag([1 2 3]),4)

samples_discrete = discretize_reflection_coefs(samples,'bins',10,'min',-1,'max',1)