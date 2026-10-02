function OptimizationExplorer

%% Main Window

fig = uifigure( ...
    'Name','Optimization Algorithms Explorer', ...
    'Position',[100 100 1600 900]);

%% Shared Data

data.method = 'Particle Swarm';

%% Top Controls

uilabel(fig,...
    'Position',[20 860 80 22],...
    'Text','Method');

methodDrop = uidropdown(fig,...
    'Position',[90 860 200 22],...
    'Items',{...
    'Particle Swarm',...
    'Gradient Ascent',...
    'Hill Climbing',...
    'Simulated Annealing'});

runBtn = uibutton(fig,...
    'Text','Run Optimization',...
    'Position',[320 855 150 30]);

%% 3D Surface

ax3D = uiaxes(fig,...
    'Position',[20 350 750 480]);

view(ax3D,45,30)

%% Contour Plot

axContour = uiaxes(fig,...
    'Position',[800 350 750 480]);

%% Parameter Panel

pPanel = uipanel(fig,...
    'Title','Parameters',...
    'Position',[20 110 600 200]);

%% Iterations

uilabel(pPanel,...
    'Text','Iterations',...
    'Position',[10 140 70 22]);

iterSlider = uislider(pPanel,...
    'Position',[100 150 250 3],...
    'Limits',[10 1000],...
    'Value',300);

%% Particles

uilabel(pPanel,...
    'Text','Particles',...
    'Position',[10 90 70 22]);

particleSlider = uislider(pPanel,...
    'Position',[100 100 250 3],...
    'Limits',[2 100],...
    'Value',20);

%% Learning Rate

uilabel(pPanel,...
    'Text','Learning Rate',...
    'Position',[10 40 90 22]);

learningSlider = uislider(pPanel,...
    'Position',[100 50 250 3],...
    'Limits',[0.001 1],...
    'Value',0.05);

%% Explanation Panel

explanationBox = uitextarea(fig,...
    'Editable','off',...
    'Position',[650 20 900 280]);

%% Objective Function

xmin = -5;
xmax = 5;

ymin = -5;
ymax = 5;

[xGrid,yGrid] = meshgrid( ...
    linspace(xmin,xmax,200));

objectiveFunction = @(x,y) ...
   -8*exp(-((x+2).^2 + (y+2).^2)/1.5) ...
   -3*exp(-((x-2).^2 + (y-2).^2)/0.5) ...
   +6*exp(-((x-2).^2 + (y+2).^2)/1.0) ...
   +2*exp(-((x+2).^2 + (y-2).^2)/0.7) ...
   +0.15*x ...
   -0.10*y ...
   -0.5*sin(0.8*x).*sin(0.8*y);

zGrid = objectiveFunction( ...
    xGrid,yGrid);

surf(ax3D,...
    xGrid,yGrid,zGrid,...
    'EdgeColor','none');

hold(ax3D,'on')

contourf(axContour,...
    xGrid,yGrid,zGrid,40);

colorbar(axContour)

%% Initial Explanation

updateExplanation()

%% Callback Wiring

methodDrop.ValueChangedFcn = @(~,~) ...
    methodChanged();

runBtn.ButtonPushedFcn = @(~,~) ...
    runOptimization();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Nested Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function methodChanged()

        data.method = methodDrop.Value;

        updateExplanation();

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function updateExplanation()

        switch data.method

            case 'Particle Swarm'

                explanationBox.Value = { ...
                'Particle Swarm Optimization'; ...
                ''; ...
                'Idea:'; ...
                'Multiple particles search simultaneously.'; ...
                ''; ...
                'Variables:'; ...
                'w  = inertia'; ...
                'c1 = personal influence'; ...
                'c2 = social influence'; ...
                ''; ...
                'Velocity:'; ...
                'v=w*v+c1*r1*(pbest-x)+c2*r2*(gbest-x)'};

            case 'Gradient Ascent'

                explanationBox.Value = { ...
                'Gradient Ascent'; ...
                ''; ...
                'Idea:'; ...
                'Follow local slope uphill.'; ...
                ''; ...
                'Variables:'; ...
                'learningRate'; ...
                ''; ...
                'Update:'; ...
                'x=x+alpha*grad'};

            case 'Hill Climbing'

                explanationBox.Value = { ...
                'Hill Climbing'; ...
                ''; ...
                'Idea:'; ...
                'Move to best neighboring point.'; ...
                ''; ...
                'Variables:'; ...
                'stepSize'};

            case 'Simulated Annealing'

                explanationBox.Value = { ...
                'Simulated Annealing'; ...
                ''; ...
                'Idea:'; ...
                'Allows occasional worse moves'; ...
                'to escape local minima.'; ...
                ''; ...
                'Variables:'; ...
                'temperature'; ...
                'coolingRate'};

        end

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function runOptimization()

        cla(ax3D)
        cla(axContour)

        surf(ax3D,...
            xGrid,yGrid,zGrid,...
            'EdgeColor','none');

        hold(ax3D,'on')

        contourf(axContour,...
            xGrid,yGrid,zGrid,40);

        switch data.method

            case 'Particle Swarm'
                runPSO();

            case 'Gradient Ascent'
                runGradient();

            case 'Hill Climbing'
                runHill();

            case 'Simulated Annealing'
                runAnnealing();

        end

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INSERT YOUR EXISTING ALGORITHMS HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function runPSO()

%% ==========================================================
% SETUP
%% ==========================================================

cla(ax3D);
cla(axContour);

surf(ax3D,...
    xGrid,yGrid,zGrid,...
    'EdgeColor','none',...
    'FaceAlpha',0.9);

hold(ax3D,'on');

view(ax3D,45,30);
shading(ax3D,'interp');

contourf(axContour,...
    xGrid,...
    yGrid,...
    zGrid,...
    40,...
    'LineColor','none');

hold(axContour,'on');
axis(axContour,'equal');

xlabel(axContour,'X');
ylabel(axContour,'Y');

%% ==========================================================
% PARAMETERS
%% ==========================================================

numParticles = round(particleSlider.Value);
maxIterations = round(iterSlider.Value);

w  = 0.6;
c1 = 1.0;
c2 = 1.0;

animationSteps = 10;

trackedParticle = 1;

%% ==========================================================
% INITIALIZE SWARM
%% ==========================================================

positions = [...
    xmin + (xmax-xmin)*rand(numParticles,1), ...
    ymin + (ymax-ymin)*rand(numParticles,1)];

velocities = zeros(numParticles,2);

particleValues = objectiveFunction(...
    positions(:,1),...
    positions(:,2));

pBestPositions = positions;
pBestValues = particleValues;

[gBestValue,idx] = min(pBestValues);
gBestPosition = pBestPositions(idx,:);

%% ==========================================================
% INITIAL VISUALIZATION
%% ==========================================================

zParticles = objectiveFunction(...
    positions(:,1),...
    positions(:,2));

particlePlot3D = plot3(...
    ax3D,...
    positions(:,1),...
    positions(:,2),...
    zParticles,...
    'ko',...
    'MarkerFaceColor','y',...
    'MarkerSize',8);

particlePlot2D = scatter(...
    axContour,...
    positions(:,1),...
    positions(:,2),...
    40,...
    'filled',...
    'MarkerFaceColor','k');

globalBestPlot = scatter(...
    axContour,...
    gBestPosition(1),...
    gBestPosition(2),...
    250,...
    'r',...
    'filled');

trackedPlot = scatter(...
    axContour,...
    positions(trackedParticle,1),...
    positions(trackedParticle,2),...
    200,...
    'm',...
    'filled');

%% ==========================================================
% TRAILS
%% ==========================================================

trailX = nan(numParticles,maxIterations);
trailY = nan(numParticles,maxIterations);

trailPlots = gobjects(numParticles,1);

for p = 1:numParticles

    trailPlots(p) = plot(...
        axContour,...
        nan,...
        nan,...
        'Color',[0.7 0.7 0.7]);

end

%% ==========================================================
% DECOMPOSED FORCE VECTORS
%% ==========================================================

momentumArrow = quiver(...
    axContour,...
    0,0,0,0,...
    'k',...
    'LineWidth',2);

personalArrow = quiver(...
    axContour,...
    0,0,0,0,...
    'b',...
    'LineWidth',2);

globalArrow = quiver(...
    axContour,...
    0,0,0,0,...
    'g',...
    'LineWidth',2);

velocityArrow = quiver(...
    axContour,...
    0,0,0,0,...
    'r',...
    'LineWidth',3);

legend(axContour,...
    {'Particles',...
     'Global Best',...
     'Tracked Particle',...
     'Momentum',...
     'Personal Best',...
     'Global Best Pull',...
     'Final Velocity'},...
     'Location','best');

%% ==========================================================
% MAIN OPTIMIZATION LOOP
%% ==========================================================

for iter = 1:maxIterations



    trackedMomentum = [0 0];
    trackedPersonal = [0 0];
    trackedGlobal = [0 0];
    trackedVelocity = [0 0];

    for i = 1:numParticles

        oldPosition = positions(i,:);

        r1 = rand;
        r2 = rand;

        momentumComponent = ...
            w*velocities(i,:);

        personalComponent = ...
            c1*r1*(...
            pBestPositions(i,:) - positions(i,:));

        globalComponent = ...
            c2*r2*(...
            gBestPosition - positions(i,:));

        newVelocity = ...
            momentumComponent + ...
            personalComponent + ...
            globalComponent;

        %% save tracked particle components

        if i == trackedParticle

            trackedMomentum = momentumComponent;
            trackedPersonal = personalComponent;
            trackedGlobal   = globalComponent;
            trackedVelocity = newVelocity;

        end

        velocities(i,:) = newVelocity;

        newPosition = ...
            positions(i,:) + velocities(i,:);

        newPosition(1) = ...
            max(min(newPosition(1),xmax),xmin);

        newPosition(2) = ...
            max(min(newPosition(2),ymax),ymin);

        %% animate movement

        for step = 1:animationSteps

            alpha = step/animationSteps;

            positions(i,:) = ...
                oldPosition + ...
                alpha*(newPosition-oldPosition);

            zParticles = objectiveFunction(...
                positions(:,1),...
                positions(:,2));

            set(particlePlot3D,...
                'XData',positions(:,1),...
                'YData',positions(:,2),...
                'ZData',zParticles);

            set(particlePlot2D,...
                'XData',positions(:,1),...
                'YData',positions(:,2));

            drawnow;

        end

        positions(i,:) = newPosition;

        currentValue = objectiveFunction(...
            positions(i,1),...
            positions(i,2));

        if currentValue < pBestValues(i)

            pBestValues(i) = currentValue;
            pBestPositions(i,:) = positions(i,:);

        end

    end

    %% ======================================================
    % GLOBAL BEST UPDATE
    %% ======================================================

    [candidateBest,idx] = min(pBestValues);

    if candidateBest < gBestValue

        gBestValue = candidateBest;
        gBestPosition = pBestPositions(idx,:);

    end

    %% ======================================================
    % UPDATE TRAILS
    %% ======================================================

    trailX(:,iter) = positions(:,1);
    trailY(:,iter) = positions(:,2);

    for p = 1:numParticles

        set(trailPlots(p),...
            'XData',trailX(p,1:iter),...
            'YData',trailY(p,1:iter));

    end

    %% ======================================================
    % UPDATE MARKERS
    %% ======================================================

    set(globalBestPlot,...
        'XData',gBestPosition(1),...
        'YData',gBestPosition(2));

    trackedPosition = positions(trackedParticle,:);

    set(trackedPlot,...
        'XData',trackedPosition(1),...
        'YData',trackedPosition(2));

    %% ======================================================
    % VECTOR DECOMPOSITION
    %% ======================================================

    set(momentumArrow,...
        'XData',trackedPosition(1),...
        'YData',trackedPosition(2),...
        'UData',trackedMomentum(1),...
        'VData',trackedMomentum(2));

    set(personalArrow,...
        'XData',trackedPosition(1),...
        'YData',trackedPosition(2),...
        'UData',trackedPersonal(1),...
        'VData',trackedPersonal(2));

    set(globalArrow,...
        'XData',trackedPosition(1),...
        'YData',trackedPosition(2),...
        'UData',trackedGlobal(1),...
        'VData',trackedGlobal(2));

    set(velocityArrow,...
        'XData',trackedPosition(1),...
        'YData',trackedPosition(2),...
        'UData',trackedVelocity(1),...
        'VData',trackedVelocity(2));

    %% ======================================================
    % TITLES
    %% ======================================================

    title(ax3D,...
        sprintf(...
        'PSO | Iteration %d/%d | Best = %.4f',...
        iter,...
        maxIterations,...
        gBestValue));

    title(axContour,...
        sprintf(...
        ['Tracked Particle Force Decomposition\n' ...
         'Black=Momentum  Blue=Personal  Green=Global  Red=Velocity']));

    drawnow;

    pause(0.05);

end

%% ==========================================================
% FINAL MARKER
%% ==========================================================

plot3(...
    ax3D,...
    gBestPosition(1),...
    gBestPosition(2),...
    gBestValue,...
    'gp',...
    'MarkerFaceColor','g',...
    'MarkerSize',20);

%% ==========================================================
% DESCRIPTION
%% ==========================================================

explanationBox.Value = {
'Particle Swarm Optimization'
''
'Contour plot represents the same objective landscape'
'as the 3D surface viewed from above.'
''
'Black Arrow = Momentum Contribution'
'Blue Arrow = Personal Best Contribution'
'Green Arrow = Global Best Contribution'
'Red Arrow = Final Velocity'
''
'PSO Equation:'
'v = w*v + c1*r1*(pBest-x) + c2*r2*(gBest-x)'
''
'Magenta Point = Tracked Particle'
'Red Point = Global Best Particle'
'Gray Lines = Particle Histories'
''
sprintf('Final Best Value = %.4f',gBestValue)
};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function runGradient()

%% ==========================================================
% RESET AXES
%% ==========================================================

cla(ax3D,'reset');
cla(axContour,'reset');

%% ==========================================================
% DRAW SURFACE
%% ==========================================================

surf(ax3D,...
    xGrid,...
    yGrid,...
    zGrid,...
    'EdgeColor','none',...
    'FaceAlpha',0.9);

hold(ax3D,'on');

view(ax3D,45,30);
shading(ax3D,'interp');

xlabel(ax3D,'X');
ylabel(ax3D,'Y');
zlabel(ax3D,'Objective');

%% ==========================================================
% DRAW CONTOUR
%% ==========================================================

contourf(axContour,...
    xGrid,...
    yGrid,...
    zGrid,...
    40,...
    'LineColor','none');

hold(axContour,'on');

axis(axContour,'equal');

xlabel(axContour,'X');
ylabel(axContour,'Y');

%% ==========================================================
% PARAMETERS
%% ==========================================================

maxIterations = round(iterSlider.Value);

% Use slider if it exists, otherwise default

try
    learningRate = learningSlider.Value;
catch
    learningRate = 0.05;
end

animationSteps = 10;

%% ==========================================================
% START LOCATION
%% ==========================================================

x = xmin + (xmax-xmin)*rand;
y = ymin + (ymax-ymin)*rand;

z = objectiveFunction(x,y);

%% ==========================================================
% STORAGE
%% ==========================================================

pathX = nan(maxIterations,1);
pathY = nan(maxIterations,1);
pathZ = nan(maxIterations,1);

%% ==========================================================
% CURRENT POINT
%% ==========================================================

currentPoint3D = plot3(ax3D,...
    x,y,z,...
    'mo',...
    'MarkerFaceColor','m',...
    'MarkerSize',10);

trail3D = plot3(ax3D,...
    x,y,z,...
    'k-',...
    'LineWidth',2);

currentPoint2D = scatter(axContour,...
    x,y,...
    150,...
    'm',...
    'filled');

trail2D = plot(axContour,...
    x,y,...
    'k-',...
    'LineWidth',2);

%% ==========================================================
% GLOBAL GRADIENT FIELD
%% ==========================================================

[qx,qy] = meshgrid(...
    linspace(xmin,xmax,15),...
    linspace(ymin,ymax,15));

u = zeros(size(qx));
v = zeros(size(qy));

h = 1e-4;

for k = 1:numel(qx)

    gx = ...
        ( objectiveFunction(qx(k)+h,qy(k)) ...
        - objectiveFunction(qx(k)-h,qy(k)) ) ...
        /(2*h);

    gy = ...
        ( objectiveFunction(qx(k),qy(k)+h) ...
        - objectiveFunction(qx(k),qy(k)-h) ) ...
        /(2*h);

    mag = sqrt(gx^2 + gy^2);

    if mag > 0

        gx = gx/mag;
        gy = gy/mag;

    end

    u(k)=gx;
    v(k)=gy;

end

quiver(axContour,...
    qx,...
    qy,...
    u,...
    v,...
    0.4,...
    'Color',[0.75 0.75 0.75]);

%% ==========================================================
% LOCAL VECTORS
%% ==========================================================

gradientArrow = quiver(axContour,...
    x,y,0,0,...
    'g',...
    'LineWidth',2);

stepArrow = quiver(axContour,...
    x,y,0,0,...
    'r',...
    'LineWidth',3);

%% ==========================================================
% MAIN LOOP
%% ==========================================================

for iter = 1:maxIterations

    %% ------------------------------------------------------
    % NUMERICAL GRADIENT
    %% ------------------------------------------------------

    dfdx = ...
        ( objectiveFunction(x+h,y) ...
        - objectiveFunction(x-h,y) ) ...
        /(2*h);

    dfdy = ...
        ( objectiveFunction(x,y+h) ...
        - objectiveFunction(x,y-h) ) ...
        /(2*h);

    gradientVector = [dfdx dfdy];

    %% ------------------------------------------------------
    % UPDATE VECTOR VISUALS
    %% ------------------------------------------------------

    gradientArrow.XData = x;
    gradientArrow.YData = y;
    gradientArrow.UData = dfdx;
    gradientArrow.VData = dfdy;

    stepVector = learningRate*gradientVector;

    stepArrow.XData = x;
    stepArrow.YData = y;
    stepArrow.UData = stepVector(1);
    stepArrow.VData = stepVector(2);

    drawnow;

    %% ------------------------------------------------------
    % TARGET LOCATION
    %% ------------------------------------------------------

    oldX = x;
    oldY = y;

    newX = x + stepVector(1);
    newY = y + stepVector(2);

    %% Bounds

    newX = max(min(newX,xmax),xmin);
    newY = max(min(newY,ymax),ymin);

    %% ------------------------------------------------------
    % ANIMATE MOTION
    %% ------------------------------------------------------

    for s = 1:animationSteps

        alpha = s/animationSteps;

        interpX = ...
            oldX + alpha*(newX-oldX);

        interpY = ...
            oldY + alpha*(newY-oldY);

        interpZ = objectiveFunction(...
            interpX,...
            interpY);

        currentPoint3D.XData = interpX;
        currentPoint3D.YData = interpY;
        currentPoint3D.ZData = interpZ;

        currentPoint2D.XData = interpX;
        currentPoint2D.YData = interpY;

        drawnow;

    end

    %% ------------------------------------------------------
    % APPLY MOVE
    %% ------------------------------------------------------

    x = newX;
    y = newY;

    z = objectiveFunction(x,y);

    pathX(iter)=x;
    pathY(iter)=y;
    pathZ(iter)=z;

    %% ------------------------------------------------------
    % UPDATE TRAILS
    %% ------------------------------------------------------

    trail3D.XData = pathX(1:iter);
    trail3D.YData = pathY(1:iter);
    trail3D.ZData = pathZ(1:iter);

    trail2D.XData = pathX(1:iter);
    trail2D.YData = pathY(1:iter);

    %% ------------------------------------------------------
    % TITLES
    %% ------------------------------------------------------

    title(ax3D,...
        sprintf(...
        'Gradient Ascent | Iteration %d/%d | Value = %.4f',...
        iter,...
        maxIterations,...
        z));

    title(axContour,...
        ['Gray = Gradient Field | ' ...
         'Green = Local Gradient | ' ...
         'Red = Step']);

    drawnow;
    pause(0.05);

    %% ------------------------------------------------------
    % CONVERGENCE
    %% ------------------------------------------------------

    if norm(stepVector) < 1e-5
        break;
    end

end

%% ==========================================================
% FINAL SOLUTION
%% ==========================================================

plot3(ax3D,...
    x,...
    y,...
    z,...
    'gp',...
    'MarkerFaceColor','g',...
    'MarkerSize',20);

scatter(axContour,...
    x,...
    y,...
    250,...
    'g',...
    'filled');

%% ==========================================================
% EXPLANATION
%% ==========================================================

explanationBox.Value = {
'Gradient Ascent'
''
'Contour plot is the top-down view'
'of the objective surface.'
''
'Gray Arrows = Global Gradient Field'
'Green Arrow = Gradient at Current Point'
'Red Arrow = Applied Step'
''
'Update Equations:'
'x = x + alpha * dfdx'
'y = y + alpha * dfdy'
''
'Black Line = Optimization Path'
'Magenta Point = Current Position'
'Green Point = Final Solution'
''
sprintf('Learning Rate = %.4f',learningRate)
sprintf('Final Value = %.4f',z)
sprintf('Final X = %.4f',x)
sprintf('Final Y = %.4f',y)
};

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function runHill()

    %% ================================================================
    % PARAMETERS FROM UI
    % ================================================================

    maxIterations = round(iterSlider.Value);

    % If you add a Hill-Climbing step-size slider later,
    % replace this with:
    %
    % stepSize = hillStepSlider.Value;

    stepSize = 0.15;

    %% ================================================================
    % RANDOM START POINT
    % ================================================================

    x = xmin + (xmax-xmin)*rand;
    y = ymin + (ymax-ymin)*rand;

    z = objectiveFunction(x,y);

    %% ================================================================
    % INITIAL GRAPHICS
    % ================================================================

    pathX = nan(maxIterations,1);
    pathY = nan(maxIterations,1);
    pathZ = nan(maxIterations,1);

    pathX(1) = x;
    pathY(1) = y;
    pathZ(1) = z;

    %% Current Point

    currentPoint3D = plot3(...
        ax3D,...
        x,y,z,...
        'ro',...
        'MarkerFaceColor','r',...
        'MarkerSize',10);

    currentPoint2D = scatter(...
        axContour,...
        x,y,...
        100,...
        'r',...
        'filled');

    %% Trail

    trail3D = plot3(...
        ax3D,...
        x,y,z,...
        'k-',...
        'LineWidth',2);

    trail2D = plot(...
        axContour,...
        x,y,...
        'k-',...
        'LineWidth',2);

    %% Candidate Points

    candidateScatter = scatter(...
        axContour,...
        nan,nan,...
        60,...
        'b',...
        'filled');

    %% Candidate Move Arrows

    candidateVectors = quiver(...
        axContour,...
        nan,nan,...
        nan,nan,...
        0,...
        'Color',[0.3 0.3 1],...
        'LineWidth',1);

    %% Best Neighbor Arrow

    bestArrow = quiver(...
        axContour,...
        x,...
        y,...
        0,...
        0,...
        0,...
        'g',...
        'LineWidth',3,...
        'MaxHeadSize',3);

    %% ================================================================
    % MAIN HILL CLIMBING LOOP
    % ================================================================

    for iter = 1:maxIterations

        currentValue = objectiveFunction(x,y);

        %% ------------------------------------------------------------
        % Generate Neighborhood
        %% ------------------------------------------------------------

        candidates = [...
            x+stepSize  y;
            x-stepSize  y;
            x           y+stepSize;
            x           y-stepSize;
            x+stepSize  y+stepSize;
            x-stepSize  y-stepSize;
            x+stepSize  y-stepSize;
            x-stepSize  y+stepSize];

        %% Keep Candidates Inside Bounds

        candidates(:,1) = ...
            max(min(candidates(:,1),xmax),xmin);

        candidates(:,2) = ...
            max(min(candidates(:,2),ymax),ymin);

        %% Evaluate All Neighbors

        candidateValues = objectiveFunction(...
            candidates(:,1),...
            candidates(:,2));

        %% Find Best Neighbor

        [bestValue,bestIdx] = max(candidateValues);

        %% ------------------------------------------------------------
        % Update Candidate Visualization
        %% ------------------------------------------------------------

        set(candidateScatter,...
            'XData',candidates(:,1),...
            'YData',candidates(:,2));

        set(candidateVectors,...
            'XData',repmat(x,8,1),...
            'YData',repmat(y,8,1),...
            'UData',candidates(:,1)-x,...
            'VData',candidates(:,2)-y);

        %% ------------------------------------------------------------
        % Check for Local Maximum
        %% ------------------------------------------------------------

        if bestValue <= currentValue

            title(ax3D,...
                sprintf(['Hill Climbing Converged ',...
                '| Local Maximum Found']));

            break

        end

        %% ------------------------------------------------------------
        % Best Move
        %% ------------------------------------------------------------

        oldX = x;
        oldY = y;

        x = candidates(bestIdx,1);
        y = candidates(bestIdx,2);

        z = objectiveFunction(x,y);

        %% Green Arrow = Accepted Neighbor

        set(bestArrow,...
            'XData',oldX,...
            'YData',oldY,...
            'UData',x-oldX,...
            'VData',y-oldY);

        %% ------------------------------------------------------------
        % Update Path
        %% ------------------------------------------------------------

        pathX(iter) = x;
        pathY(iter) = y;
        pathZ(iter) = z;

        %% ------------------------------------------------------------
        % Update Graphics
        %% ------------------------------------------------------------

        set(currentPoint3D,...
            'XData',x,...
            'YData',y,...
            'ZData',z);

        set(currentPoint2D,...
            'XData',x,...
            'YData',y);

        set(trail3D,...
            'XData',pathX(1:iter),...
            'YData',pathY(1:iter),...
            'ZData',pathZ(1:iter));

        set(trail2D,...
            'XData',pathX(1:iter),...
            'YData',pathY(1:iter));

        %% ------------------------------------------------------------
        % Titles
        %% ------------------------------------------------------------

        title(ax3D,...
            sprintf(['Hill Climbing | Iteration %d/%d ',...
            '| Value = %.4f'],...
            iter,...
            maxIterations,...
            z));

        title(axContour,...
            ['Blue Dots = Neighbor Candidates | ' ...
             'Blue Arrows = Possible Moves | ' ...
             'Green Arrow = Chosen Move']);

        drawnow;

        pause(0.05);

    end

    %% ================================================================
    % FINAL MARKER
    % ================================================================

    plot3(...
        ax3D,...
        x,...
        y,...
        z,...
        'gp',...
        'MarkerFaceColor','g',...
        'MarkerSize',24);

    scatter(...
        axContour,...
        x,...
        y,...
        250,...
        'm',...
        'filled');

    %% ================================================================
    % EXPLANATION PANEL
    % ================================================================

    explanationBox.Value = {
    'Hill Climbing'
    ''
    'Idea:'
    'Evaluate neighboring positions and move'
    'to the best available neighbor.'
    ''
    'Process:'
    '1. Inspect all nearby points.'
    '2. Select highest-value neighbor.'
    '3. Move there.'
    '4. Repeat until no improvement exists.'
    ''
    'Strengths:'
    'Very simple and fast.'
    ''
    'Weaknesses:'
    'Frequently becomes trapped'
    'at local maxima.'
    ''
    'Blue Dots: Neighbor candidates'
    'Blue Arrows: All possible moves'
    'Green Arrow: Selected move'
    'Black Line: Optimization path'
    ''
    sprintf('Step Size = %.3f',stepSize)
    sprintf('Final Value = %.4f',z)
    sprintf('Final X = %.4f',x)
    sprintf('Final Y = %.4f',y)
    };

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function runAnnealing()

    %% ================================================================
    % PARAMETERS FROM UI
    % ================================================================

    maxIterations = round(iterSlider.Value);

    % If you later add dedicated Annealing sliders:
    %
    % temperature = tempSlider.Value;
    % coolingRate = coolingSlider.Value;
    % stepSize = annealingStepSlider.Value;

    temperature = 5;
    coolingRate = 0.98;
    stepSize = 0.5;

    %% ================================================================
    % RANDOM STARTING LOCATION
    % ================================================================

    x = xmin + (xmax-xmin)*rand;
    y = ymin + (ymax-ymin)*rand;

    currentValue = objectiveFunction(x,y);

    bestX = x;
    bestY = y;
    bestValue = currentValue;

    %% ================================================================
    % PATH STORAGE
    % ================================================================

    pathX = nan(maxIterations,1);
    pathY = nan(maxIterations,1);
    pathZ = nan(maxIterations,1);

    pathX(1) = x;
    pathY(1) = y;
    pathZ(1) = currentValue;

    %% ================================================================
    % CURRENT POSITION
    % ================================================================

    currentPoint3D = plot3(...
        ax3D,...
        x,y,currentValue,...
        'ro',...
        'MarkerFaceColor','r',...
        'MarkerSize',10);

    currentPoint2D = scatter(...
        axContour,...
        x,y,...
        100,...
        'r',...
        'filled');

    %% ================================================================
    % BEST POSITION
    % ================================================================

    bestPoint3D = plot3(...
        ax3D,...
        bestX,bestY,bestValue,...
        'gp',...
        'MarkerFaceColor','g',...
        'MarkerSize',16);

    bestPoint2D = scatter(...
        axContour,...
        bestX,bestY,...
        150,...
        'g',...
        'filled');

    %% ================================================================
    % PATH
    % ================================================================

    trail3D = plot3(...
        ax3D,...
        x,y,currentValue,...
        'k-',...
        'LineWidth',2);

    trail2D = plot(...
        axContour,...
        x,y,...
        'k-',...
        'LineWidth',2);

    %% ================================================================
    % PROPOSED MOVE VISUALIZATION
    % ================================================================

    proposalArrow = quiver(...
        axContour,...
        x,y,...
        0,0,...
        0,...
        'b',...
        'LineWidth',2,...
        'MaxHeadSize',3);

    proposalPoint = scatter(...
        axContour,...
        nan,nan,...
        80,...
        'b',...
        'filled');

    %% ================================================================
    % ACCEPTED / REJECTED INDICATOR
    % ================================================================

    acceptText = text(...
        axContour,...
        xmin+0.5,...
        ymax-0.5,...
        '',...
        'FontSize',12,...
        'FontWeight','bold');

    %% ================================================================
    % TEMPERATURE HISTORY
    % ================================================================

    tempHistory = nan(maxIterations,1);

    %% ================================================================
    % MAIN LOOP
    % ================================================================

    for iter = 1:maxIterations

        %% ------------------------------------------------------------
        % PROPOSE RANDOM MOVE
        %% ------------------------------------------------------------

        candidateX = x + randn*stepSize;
        candidateY = y + randn*stepSize;

        %% Keep Inside Domain

        candidateX = ...
            max(min(candidateX,xmax),xmin);

        candidateY = ...
            max(min(candidateY,ymax),ymin);

        %% ------------------------------------------------------------
        % VISUALIZE PROPOSED MOVE
        %% ------------------------------------------------------------

        set(proposalArrow,...
            'XData',x,...
            'YData',y,...
            'UData',candidateX-x,...
            'VData',candidateY-y);

        set(proposalPoint,...
            'XData',candidateX,...
            'YData',candidateY);

        %% ------------------------------------------------------------
        % EVALUATE
        %% ------------------------------------------------------------

        candidateValue = objectiveFunction(...
            candidateX,...
            candidateY);

        delta = candidateValue - currentValue;

        accepted = false;

        %% ------------------------------------------------------------
        % ACCEPTANCE TEST
        %% ------------------------------------------------------------

        if delta < 0

            % Better solution

            accepted = true;

        else

            probability = ...
                exp(-delta/temperature);

            if rand < probability

                accepted = true;

            end

        end

        %% ------------------------------------------------------------
        % APPLY MOVE
        %% ------------------------------------------------------------

        if accepted

            set(proposalArrow,'Color','g');
            set(proposalPoint,'MarkerFaceColor','g');

            x = candidateX;
            y = candidateY;
            currentValue = candidateValue;

            acceptText.String = 'ACCEPTED';

            acceptText.Color = [0 0.6 0];

        else

            set(proposalArrow,'Color','r');
            set(proposalPoint,'MarkerFaceColor','r');

            acceptText.String = 'REJECTED';

            acceptText.Color = [0.8 0 0];

        end

        %% ------------------------------------------------------------
        % BEST SOLUTION
        %% ------------------------------------------------------------

        if currentValue < bestValue

            bestValue = currentValue;
            bestX = x;
            bestY = y;

        end

        %% ------------------------------------------------------------
        % SAVE HISTORY
        %% ------------------------------------------------------------

        pathX(iter) = x;
        pathY(iter) = y;
        pathZ(iter) = currentValue;

        tempHistory(iter) = temperature;

        %% ------------------------------------------------------------
        % COOL SYSTEM
        %% ------------------------------------------------------------

        temperature = ...
            temperature * coolingRate;

        %% ------------------------------------------------------------
        % UPDATE GRAPHICS
        %% ------------------------------------------------------------

        set(currentPoint3D,...
            'XData',x,...
            'YData',y,...
            'ZData',currentValue);

        set(currentPoint2D,...
            'XData',x,...
            'YData',y);

        set(bestPoint3D,...
            'XData',bestX,...
            'YData',bestY,...
            'ZData',bestValue);

        set(bestPoint2D,...
            'XData',bestX,...
            'YData',bestY);

        set(trail3D,...
            'XData',pathX(1:iter),...
            'YData',pathY(1:iter),...
            'ZData',pathZ(1:iter));

        set(trail2D,...
            'XData',pathX(1:iter),...
            'YData',pathY(1:iter));

        %% ------------------------------------------------------------
        % TITLES
        %% ------------------------------------------------------------

        title(ax3D,...
            sprintf(['Simulated Annealing | Iteration %d/%d | ',...
            'Temp = %.3f | Best = %.4f'],...
            iter,...
            maxIterations,...
            temperature,...
            bestValue));

        title(axContour,...
            ['Blue = Proposed Move | ' ...
             'Green = Accepted Move | ' ...
             'Red = Rejected Move']);

        drawnow;

        pause(0.03);

        %% ------------------------------------------------------------
        % STOP IF TEMPERATURE TOO LOW
        %% ------------------------------------------------------------

        if temperature < 1e-4
            break
        end

    end

    %% ================================================================
    % FINAL MARKER
    % ================================================================

    plot3(...
        ax3D,...
        bestX,...
        bestY,...
        bestValue,...
        'mp',...
        'MarkerSize',24,...
        'MarkerFaceColor','m');

    scatter(...
        axContour,...
        bestX,...
        bestY,...
        250,...
        'm',...
        'filled');

    %% ================================================================
    % UPDATE EXPLANATION PANEL
    % ================================================================

    explanationBox.Value = {
    'Simulated Annealing'
    ''
    'Idea:'
    'Randomly explores the search space and'
    'occasionally accepts worse solutions.'
    ''
    'Why it works:'
    'The acceptance of worse moves allows'
    'escape from local minima.'
    ''
    'Acceptance Probability:'
    'P = exp(-Delta/T)'
    ''
    'Variables:'
    'Temperature  -> Controls randomness'
    'Cooling Rate -> Lowers temperature'
    'Step Size    -> Jump distance'
    ''
    'Green Arrow: Accepted Move'
    'Red Arrow: Rejected Move'
    'Black Line: Search Path'
    'Green Point: Best Found So Far'
    'Magenta Point: Final Best Solution'
    ''
    sprintf('Final Temperature = %.6f',temperature)
    sprintf('Best Value = %.4f',bestValue)
    sprintf('Best X = %.4f',bestX)
    sprintf('Best Y = %.4f',bestY)
    };

end

end