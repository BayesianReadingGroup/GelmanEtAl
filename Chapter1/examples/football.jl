
using CSV
using DataFrames
using Gadfly,Cairo,Fontconfig
using Statistics,StatsFuns,SpecialFunctions

footballData = DataFrame(CSV.File("football_data.csv"))

footballData.difference = footballData.favorite - footballData.underdog
footballData.error = footballData.spread - footballData.difference

if false
    plt=plot(footballData,x=:spread,y=:difference,
             Theme(default_color="red",point_size=1pt,background_color="white",highlight_width=0pt),
             Stat.x_jitter(range=0.5),
             Stat.y_jitter(range=0.5),
             Geom.point,
             Coord.Cartesian(xmin=-0.5,xmax=20.5)
             )
    
    draw(PDF("spreadVdiff.pdf",8cm,8cm),plt)
end

if false
    footballData.integerSpread=round.(footballData.spread).==footballData.spread

    means = groupby(footballData, :integerSpread)
    means = combine(means, nrow, :error => mean => :mean)

    layer1=layer(footballData,x=:integerSpread,y=:error,Geom.violin)
    layer2=layer(means,x=:integerSpread, y=:mean, shape=[Shape.hline],Geom.point,Theme(default_color="black",point_size=2.5mm));
    plt=plot(layer2,layer1,Theme(background_color="white"))
    
    draw(PDF("integerSpread.pdf",8cm,8cm),plt)

end

σModel=14.0

modelResult(spread) = 0.5+0.5erf(spread /(sqrt(2)*σModel))


