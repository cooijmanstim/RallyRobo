% play the monte-carlo strategy against a random one
clear classes; clear all;
init();

ngames = 1000;
nwins = zeros(1, 4);
for j = 1:ngames
    clc; close all;
    game = RallyRobo.Game.example_game_1v1();
    % the first robot uses the monte carlo strategy
    % the second uses the random search strategy
    game.robots.get(0).set_strategy(RallyRobo.Strategy.MonteCarloHeuristicSmart);
    game.robots.get(1).set_strategy(RallyRobo.Strategy.RandomSearchHeuristicSlow);
    
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
            if game.is_over()
                break;
            end
            
            game.process_register(i-1);
            refreshBoard(game);
        
            for k = 1:game.robots.size()
                robot = game.robots.get(k-1);
                display(sprintf('robot %i position %s direction %i damage %i next_checkpoint %i', ...
                                k, num2str(robot.position(:)'), ...
                                robot.direction.ordinal(), ...
                                robot.damage, ...
                                robot.next_checkpoint));
            end
        end
        
        if game.is_over()
            break;
        end
        
        % remove destroyed robots, respawn waiting robots, etc.
        game.finalize_turn();
        refreshBoard(game);
    end
    
    nwins(game.winner()+1) = nwins(game.winner()+1) + 1;
end
