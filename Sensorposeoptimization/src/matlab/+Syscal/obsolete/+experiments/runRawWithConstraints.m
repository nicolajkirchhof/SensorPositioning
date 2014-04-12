%% use different accuracys
%% testing
cnt=1;
i = 10;
j = 3;

%%

% jacobian = {'on', 'off'};
% for cnt=1:2
%     for i = 1:10
%         for j = 1:3

%%
malg = {'trust-region-reflective' , {'levenberg-marquardt', 0.01'}};
%mstd = [(.2:0.2:2)',(0.2:0.2:2)'];
mstd = {'room',''};
msens = [(0.1:0.1:1)',(0.1:0.1:1)',(0.1:1:10)'*pi/180];

scalraw = syscal.createRunParameters('tcraw1', 'rnd',  mstd, msens(i,:));

%%
scalraw = syscal.createTestCase(20, 0.1);

hraw = syscal.plotState(scalraw);
scalraw.userData.plotHandle = hraw;
scalraw.userData.plotState = true;
funraw = @(x) syscal.calcStateRaw(x, scalraw);
[scalraw, resultraw] = syscal.calcOptimization(scalraw, funraw, malg{cnt}, 'off', true);
%%
%
%             scallh = syscal.copyScal(scalaoajon);
%             hlh = syscal.plotState(scallh);
%             scallh.userData.plotHandle = hlh;
%             scallh.userData.plotState = true;
%             funlh = @(x) syscal.calcStateLh(x, scallh);
%             [scallh, resultlh] = syscal.calcOptimization(scallh, funlh, malg{cnt}, 'off', true);
%

save(['res/mat/evTcraw1AoaRawLh' num2str(cnt) num2str(i) num2str(j)]);
close all; clear scal;
%         end
%     end
% end
%%
%
% for cnt=1:2
%     for i = 1:10
%         for j = 1:3
%
%             malg = {'trust-region-reflective' , {'levenberg-marquardt', 0.01'}};
%             mstd = [(.2:0.2:2)',(0:0.2:2)'];
%             msens = [(0.1:0.1:1)',(0.1:0.1:1)',(0.1:1:10)'*pi/180];
%
%             for jac = 1:2
%                 [scal, result] = syscal.calcFsolveAoa('tcraw1', mstd(i,:), msens(i,:), malg{cnt}, jacobian{jac});
%
%                 save(['res/mat/evaoaj' jacobian{jac} num2str(cnt) num2str(i) num2str(j)]);
%                 close all; clear scal;
%             end
%         end
%     end
% end
%
%
% %% measures somewhere in room
% for cnt=1:2
%     for i = 1:10
%         for j = 1:3
%
%             malg = {'trust-region-reflective' , {'levenberg-marquardt', 0.01'}};
%             mstd = [(.2:0.2:2)',(0:0.2:2)'];
%             msens = [(0.1:0.1:1)',(0.1:0.1:1)',(0.1:1:10)'*pi/180];
%
%             for jac = 1:2
%                 [scal, result] = syscal.calcFsolveAoa('tcraw1', mstd(i,:), msens(i,:), malg{cnt}, jacobian{jac});
%
%                 save(['res/mat/evaoaj' jacobian{jac} num2str(cnt) num2str(i) num2str(j)]);
%                 close all; clear scal;
%             end
%         end
%     end
% end
%
% for cnt=1:2
%     for i = 1:10
%         for j = 1:3
%
%             malg = {'trust-region-reflective' , {'levenberg-marquardt', 0.01'}};
%             mstd = [(.2:0.2:2)',(0:0.2:2)'];
%             msens = [(0.1:0.1:1)',(0.1:0.1:1)',(0.1:1:10)'*pi/180];
%
%             for jac = 1:2
%                 [scal, result] = syscal.calcFsolveAoa('tcraw1', mstd(i,:), msens(i,:), malg{cnt}, jacobian{jac});
%
%                 save(['res/mat/evaoaj' jacobian{jac} num2str(cnt) num2str(i) num2str(j)]);
%                 close all; clear scal;
%             end
%         end
%     end
% end