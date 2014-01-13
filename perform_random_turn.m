% testing the java interface

clear; clc; close();
init();
game = RallyRobo.Game.example_game();
initBoardFigure(game);
refreshBoard(game);

nturns = 3;
for j = 1:nturns
    RallyRobo.Card.fill_empty_registers_randomly(game);
    for k = 1:game.robots.size()
        robot = game.robots.get(k-1);
        display(sprintf('robot %i registers %s', ...
                        k, num2str(robot.registers(:)')));
    end
    
    for i = 1:RallyRobo.Robot.NRegisters
        keyboard;
        game.process_register(i-1);
        refreshBoard(game);
        
        for k = 1:game.robots.size()
            robot = game.robots.get(k-1);
            display(sprintf('robot %i position %s direction %i', ...
                            k, num2str(robot.position(:)'), robot.direction.ordinal()));
        end
    end
    game.finalize_turn();
end
