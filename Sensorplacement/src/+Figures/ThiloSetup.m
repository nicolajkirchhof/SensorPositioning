close all;
clear all;
%%
cla;
axis equal
hold on;
axis off
xlim([-300 8300]);
ylim([-300 8300]);

pixel_fov = 6;
distance = 3000;
sensor = struct('position', [], 'pixelpoly', {}, 'phi_deg', []);
sensor(1).position = [0 0];
sensor(1).phi_deg = [0];
sensor(2).position = [8000, 0];
sensor(2).phi_deg = 90;
sensor(3).position = [8000, 7000];
sensor(3).phi_deg = 180;
sensor(4).position = [0, 7000];
sensor(4).phi_deg = 270;

for ids = 1:4
   for idpix = 1:16 
       if idpix <= 8
       pix_offset = sensor(ids).phi_deg+(idpix-1)*pixel_fov;
       end
       if idpix > 8
       pix_offset = sensor(ids).phi_deg+90-(17-idpix)*pixel_fov;
       end
       pixfov = circleArcToPolyline([sensor(ids).position, distance, pix_offset, pixel_fov], 128);
       pixfov = [sensor(ids).position;pixfov];
       drawPolygon(pixfov, 'color', 'k');
       fillPolygon(pixfov, 0.7*ones(1,3));
   end
end

%elevated
distance = 6000;

ids = 1;
idpix = 7;
       pix_offset = sensor(ids).phi_deg+(idpix-1)*pixel_fov;
       pixfov = circleArcToPolyline([sensor(ids).position, distance, pix_offset, pixel_fov], 128);
       pixfov = [sensor(ids).position;pixfov];
       drawPolygon(pixfov, 'color', 'k');
       fillPolygon(pixfov, 'k', 'facealpha', 0.2);
e1 = pixfov;
       
ids = 2;
idpix = 10
       if idpix <= 8
       pix_offset = sensor(ids).phi_deg+(idpix-1)*pixel_fov;
       end
       if idpix > 8
       pix_offset = sensor(ids).phi_deg+90-(17-idpix)*pixel_fov;
       end
       pixfov = circleArcToPolyline([sensor(ids).position, distance, pix_offset, pixel_fov], 128);
       pixfov = [sensor(ids).position;pixfov];
       drawPolygon(pixfov, 'color', 'k');
       fillPolygon(pixfov, 'k', 'facealpha', 0.2);
e2 = pixfov;

ids = 3;
idpix = 8
       if idpix <= 8
       pix_offset = sensor(ids).phi_deg+(idpix-1)*pixel_fov;
       end
       if idpix > 8
       pix_offset = sensor(ids).phi_deg+90-(17-idpix)*pixel_fov;
       end
       pixfov = circleArcToPolyline([sensor(ids).position, distance, pix_offset, pixel_fov], 128);
       pixfov = [sensor(ids).position;pixfov];
       drawPolygon(pixfov, 'color', 'k');
       fillPolygon(pixfov, 'k', 'facealpha', 0.2);
e3 = pixfov;
       

       
plot(4100,3200, 'marker', 'o', 'markersize', 8, 'markerfacecolor', 'k',  'markeredgecolor', 'k');

text(-600, -300, '$S_1$');
text(8000, -300, '$S_2$');
text(8000, 7300, '$S_3$');
text(-600, 7300, '$S_4$');

room = [0 0; 8000 0; 8000 7000; 0 7000; 0, 0];
drawPolyline(room, 'color', 'k', 'linewidth', 2);
Figures.makeFigure('ThiloSetup');
%%
% filename = '../../Dissertation/Thesis/Figures/ThiloSetup.tikz';
% matlab2tikz(filename, 'parseStrings', false,...
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '11cm',...
% ...    'height', '5cm', 
%     'extraAxisOptions',{'y post scale=1'});
% stn(filename);
