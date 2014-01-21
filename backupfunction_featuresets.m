function [featuresets, featureset_order] = backupfunction_featuresets()
import RallyRobo.Feature;
featuresets = {};
featuresets{5} = Feature.Pit;
featuresets{6} = Feature.WallWest;
featuresets{7} = Feature.WallEast;
featuresets{8} = Feature.WallNorth;
featuresets{9} = Feature.WallSouth;
featuresets{10} = [Feature.WallEast Feature.WallNorth];
featuresets{11} = [Feature.WallEast Feature.WallSouth];
featuresets{12} = [Feature.WallWest Feature.WallNorth];
featuresets{13} = [Feature.WallWest Feature.WallSouth];
featuresets{14} = Feature.ConveyorWest;
featuresets{15} = Feature.ConveyorEast;
featuresets{16} = Feature.ConveyorSouth;
featuresets{17} = Feature.ConveyorNorth;
featuresets{18} = [Feature.ConveyorEast Feature.ConveyorTurningCw];
featuresets{19} = [Feature.ConveyorSouth Feature.ConveyorTurningCw];
featuresets{20} = [Feature.ConveyorWest Feature.ConveyorTurningCw];
featuresets{21} = [Feature.ConveyorNorth Feature.ConveyorTurningCw];
featuresets{22} = [Feature.ConveyorSouth Feature.ConveyorTurningCcw];
featuresets{23} = [Feature.ConveyorEast Feature.ConveyorTurningCcw];
featuresets{24} = [Feature.ConveyorNorth Feature.ConveyorTurningCcw];
featuresets{25} = [Feature.ConveyorWest Feature.ConveyorTurningCcw];
featuresets{26} = Feature.Repair;

% composites-first order to make life easier in the inverse
featureset_order = [18:25 10:13 26 14:17 5:9];
