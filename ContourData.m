classdef ContourData
    properties
        ScaledPoints
        Points
        scaledXX
        scaledYY
        XX
        YY
        Area
        Shape
        Perimeter
        Circularity
    end
    
    methods
        function obj = ContourData(scaledPoints, Points)
            obj.ScaledPoints = scaledPoints;
            obj.scaledXX = scaledPoints(1,:);
            obj.scaledYY = scaledPoints(2,:);
            obj.Points = Points;
            obj.XX = Points(1,:);
            obj.YY = Points(2,:);
            obj.Shape = polyshape(obj.XX, obj.YY);
            obj.Area = area(obj.Shape);
            obj.Perimeter = perimeter(obj.Shape);
            obj.Circularity = (4 * pi * obj.Area)/(obj.Perimeter .^ 2); 

        end
        
        function Draw(obj, axes)
            hold on;
            plot(axes, obj.scaledXX, obj.scaledYY, 'r','LineWidth',2);
        end

    end
end

