clear all;
close all;

%----------------------------------------------------------------
% 各種パラメータ及び初期設定
%----------------------------------------------------------------
nx = 30;
ny = 30;
range = 1;
N = nx * ny;

I = 0.2;        %感染率
R = 0.385;      %治癒率
D = 0.0004 * R; %死亡率
F = 5;         %初期感染者数
nt_max = 30;
nt_interval = nt_max / 20;

infP = zeros(nx, ny);
infT = zeros(nx, ny);
infR = zeros(2 * range + 1, 2 * range + 1)
imm = zeros(nx, ny);
dead = zeros(nx, ny);

infP_trans = zeros(nt_max + 1, 1);
deadP_trans = zeros(nt_max + 1, 1);
immP_trans = zeros(nt_max + 1, 1);

infP_trans(1, 1) = F;   %初期感染者数記録

for ii = 1 : F
    x = floor(nx * rand) + 1;
    y = floor(ny * rand) + 1;

    if x == 11 | y == 11
        ii = ii - 1;
    elseif infP(x, y) == 1
        ii = ii - 1;
    else
        infP(x, y) = 1;
        infT(x, y) = 1;
    end
end



i1p = zeros(nx, 1); i1m = zeros(nx, 1);
for ii = 1: nx
    i1m(ii) = ii - 1;
    i1p(ii) = ii + 1;
end
i1m(1) = 0; i1p(nx) = 0;

j1p = zeros(1, ny); j1m = zeros(1, ny);
for jj = 1: ny
    j1m(jj) = jj - 1;
    j1p(jj) = jj + 1;
end
j1m(1) = 0; j1p(ny) = 0;


n_fig = 2;
figure(n_fig); clf;

for x = 1 : nx
    for y = 1 : ny
        if infP(x, y) == 1
            plot(x, y,'r*');
            hold on;
        else
            plot(x, y,'go');
            hold on;
        end
    end
end

title('Infection status','fontsize',20);
axis([0, nx + 1, 0, ny + 1]);
axis('square');
text(nx + 2, ny,'✳︎','Color','red','fontsize',20); text(nx + 4, ny,':infection','fontsize',17);
text(nx + 2, ny - 2,'◯','Color','green','fontsize',16); text(nx + 4, ny - 2,':healthy','fontsize',17);
text(nx + 2, ny - 4,'□','Color','blue','fontsize',16); text(nx + 4, ny - 4,':recover','fontsize',17);
eval(sprintf('print res/pand_%d.jpg', n_fig - 1));
n_fig = n_fig + 1;

for nt = 1 : nt_max
    for ii = 1 : nx
        for jj = 1 : ny

            if infP(ii, jj) == 1
                %感染拡大

                if infT(ii, jj) > 0
                    pandArray = rand(3, 3);

                    for x = 1 : 3
                        for y = 1 : 3
                            if pandArray(x, y) < I
                                pandArray(x, y) = 1;
                            else
                                pandArray(x, y) = 0;
                            end
                        end
                    end

                    if i1m(ii) == 0
                        for y = 1 : 3
                            pandArray(1, y) = 0;
                        end
                    end

                    if i1p(ii) == 0
                        for y = 1 : 3
                            pandArray(3, y) = 0;
                        end
                    end

                    if j1m(jj) == 0
                        for x = 1 : 3
                            pandArray(x, 1) = 0;
                        end
                    end

                    if j1p(jj) == 0
                        for x = 1 : 3
                            pandArray(x, 3) = 0;
                        end
                    end
                    %pandArray

                    for x = 1 : 3
                        for y = 1 : 3
                            if pandArray(x, y) == 1
                                if imm(ii + x - 2, jj + y - 2) == 0
                                    infP(ii + x - 2, jj + y - 2) = 1;
                                end
                            end
                        end
                    end

                end


                %回復,死亡関係
                infT(ii, jj) = infT(ii, jj) + 1;
                decision = rand;

                if decision > 1 - R / 2
                    infP(ii, jj) = 0;
                    imm(ii, jj) = 1;
                    immP_trans(nt + 1, 1) = immP_trans(nt + 1, 1) + 1;
                else
                    if decision < D
                        dead(ii, jj) = 1;
                    end
                end

            end


            if infP(ii, jj) == 1
                infP_trans(nt + 1, 1) = infP_trans(nt + 1, 1) + 1;
            end

            if dead(ii, jj) == 1
                deadP_trans(nt + 1, 1) = deadP_trans(nt + 1, 1) + 1;
            end

        end
    end



    if mod(nt, nt_interval) == 0


        figure(n_fig); clf;

        for x = 1 : nx
            for y = 1 : ny
                if dead(x, y) == 0
                    if imm(x, y) == 1
                        plot(x, y, 'bs')
                    else
                        if infP(x, y) == 1
                            plot(x, y,'r*');
                            hold on;
                        else
                            plot(x, y,'go');
                            hold on;
                        end
                    end
                end
            end
        end

        title('Infection status','fontsize',20);
        text(nx + 2, ny - 10, [' t = ', num2str(nt)], 'fontsize', 20, 'fontname', 'times');
        text(nx + 2, ny,'✳︎','Color','red','fontsize',20); text(nx + 4, ny,':infection','fontsize',17);
        text(nx + 2, ny - 2,'◯','Color','green','fontsize',16); text(nx + 4, ny - 2,':healthy','fontsize',17);
        text(nx + 2, ny - 4,'□','Color','blue','fontsize',16); text(nx + 4, ny - 4,':recover','fontsize',17);
        axis([0, nx + 1, 0, ny + 1]);

        axis('square');
        
        if n_fig - 1 < 10
            eval(sprintf('print res/pand_0%d.jpg', n_fig - 1));
        else
            eval(sprintf('print res/pand_%d.jpg', n_fig - 1));
        end

        n_fig = n_fig + 1;
    end
end


figure(1); clf;
plot(immP_trans, '-b');
hold on;
plot(deadP_trans, '-k');
hold on;
plot(infP_trans, '-r');
hold on;
legend('recover', 'dead', 'infection')
xlabel('t','fontsize', 20, 'fontname', 'times');
ylabel('Number of people', 'fontsize', 20, 'fontname', 'times');
ax = gca; set(ax, 'plotboxaspectratio', [1.5,1,1]);
print res/statistics.jpg
