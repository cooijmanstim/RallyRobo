% play the monte-carlo strategy against a random one
init();

ngames = 1;
nwins = [];
for j = 1:ngames
    clear classes; clear all; clc; close all;
    % TODO: come up with a fair two-player board to test strategies
    % one-on-one.
    game = RallyRobo.Game.example_game();
    % the first robot uses the monte carlo strategy, all the others
    % use the random strategy.
    game.robots.get(0).set_strategy(RallyRobo.Strategy.MonteCarlo);
    initBoardFigure(game);
    refreshBoard(game);

    while ~game.is_over()
        % deal hands and fill registers according to players' strategies
        game.fill_registers();
        
        for k = 1:game.robots.size()
            robot = game.robots.get(k-1);
            display(sprintf('robot %i registers %s', ...
                            k, num2str(robot.registers(:)')));
        end
    
        for i = 1:RallyRobo.Robot.NRegisters
            game.process_register(i-1);
            refreshBoard(game);
        
            for k = 1:game.robots.size()
                robot = game.robots.get(k-1);
                display(sprintf('robot %i position %s direction %i', ...
                                k, num2str(robot.position(:)'), robot.direction.ordinal()));
            end
        end
        
        % remove destroyed robots, respawn waiting robots, etc.
        game.finalize_turn();
    end
    
    nwins(game.winner.identity-1) = nwins(game.winner.identity-1) + 1;
end
