function [userposition, currentdirection] = findposition(tiles,robotID)
%17-20 represent 1st robot facing respectively right up left down
%21-24 represent 2nd robot facing respectively right up left down
%25-28 represent 3rd robot facing respectively right up left down
%29-32 represent 4th robot facing respectively right up left down
    for k = (17+(4*(robotID-1))):(20+(4*(robotID-1)))

        if(nnz(tiles(:,:,k) > 0))
            [userposition(1), userposition(2)] = find(tiles(:,:,k));
            currentdirection = k -(4*(robotID-1)) - 17;
            break;
        end
    end
end