function xn = NewtonRhapsonSolver(f, v, x, known, iterations, maxError)

J = {};

for i = known
    eval([char(i{1}{1}) '= i{1}{2};']);
end
for i = 1:length(v)
    eval([char(v{i}) '= x(i);']);
end

% create Jacobi matrix
for j = 1:size(v, 1)
    for i = 1:size(f,1)
        J{i, j} = diff(f{i}, v{j});
    end
end

e = zeros(size(f));
xn = x;
Jeval = zeros(size(J));
feval = zeros(size(f));

figure = gca;
hold on;

for it = 1:iterations 
    for i = 1:size(f,1)
        feval(i) = subs(f{i});
        for j = 1:size(v, 1)
            Jeval(i,j) = subs(J{i, j});
        end
    end
        
    %xs = NewtonRhapsonUpdate(J, xs, f);
    dx = -Jeval\feval;
    
    xn = xn + dx;
    % map dx to symbols
    for i = 1:length(v)
        eval([char(v{i}) '= xn(i);']);
    end
       
    % Evaluate result
    for i = 1:size(f, 1)
        e(i) = subs(f{i});
    end
    
    plot(it, norm(e), 'x');
    if norm(e) < maxError
        return;
    end
end