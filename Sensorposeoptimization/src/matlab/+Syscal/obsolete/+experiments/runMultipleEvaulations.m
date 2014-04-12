jacobian = {'on', 'off'};
for jac = 1:2
    for cnt=1:2
        for i = 1:10
            for j = 1:3
                
                malg = {'trust-region-reflective' , {'levenberg-marquardt', 0.01'}};
                mstd = [(0:0.2:2)',(0:0.2:2)'];
                msens = [(0:0.1:1)',(0:0.1:1)',(0:1:10)'*pi/180];
                
                [scal, result] = syscal.calcFsolveAoa('tcraw1', mstd(i,:), msens(i,:), malg{cnt}, jacobian{jac});
                
                save(['res/mat/evaoaj' jacobian{jac} num2str(cnt) num2str(i) num2str(j)]);
                close all; clear scal;
            end
        end
    end
end