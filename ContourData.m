classdef ContourData
    properties
        Points
        XX
        YY
        Area
        Shape
        Perimeter
        Circularity
    end
    
    methods
        function obj = ContourData(points)
            obj.Points = points;
            obj.XX = points(1,:);
            obj.YY = points(2,:);
            obj.Shape = polyshape(obj.XX, obj.YY);
            obj.Area = area(obj.Shape);
            obj.Perimeter = perimeter(obj.Shape);
            obj.Circularity = (4 * pi * obj.Area)/(obj.Perimeter .^ 2); 

        end
        
        function Draw(obj, axes)
            hold on;
            plot(axes, obj.XX, obj.YY, 'r','LineWidth',2);
        end

    end
end

