function [kernel] = Disk_kernel(radius)
    diameter = 2 * radius + 1;

    kernel = zeros(diameter, diameter);

    middle = round(diameter / 2);
    kernel(middle,:) = 1;
    kernel(:,middle) = 1;

    for x = 1 : 1 : diameter
        for y = 1 : 1 : diameter
            distance = round(CalculateDistance(abs(middle - x), abs(middle - y)));
            if distance <= radius
                kernel(x, y) = 1;
            end
        end
    end
end

function distance = CalculateDistance(x, y)
    distance = sqrt(x * x + y * y);
end
