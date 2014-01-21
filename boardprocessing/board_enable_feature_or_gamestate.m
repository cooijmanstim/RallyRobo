function [game] = board_enable_feature_or_gamestate(game, x,isGameState, featureOrGamestate, player)
if isGameState
    if isempty(featureOrGamestate.checkpointid)
        game.nrobots = game.nrobots +1;
        game.state.robots(player).position = x;
        game.state.robots.direction = featureOrGamestate.robotdir;
    else
        game.ncheckpoints = game.ncheckpoints +1;
        game.state.checkpoints(featureOrGamestate.checkpointid) = x;
    end
else
    game.board(x(1), x(2),:) = featureOrGamestate;
end
end