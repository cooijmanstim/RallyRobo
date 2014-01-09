function [game] = game_add_checkpoint(game, x)
    game.checkpoints = [game.checkpoints; x];
