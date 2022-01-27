
using CSV, DataFrames
using Gadfly,Cairo,Fontconfig
using Statistics,StatsFuns,SpecialFunctions
using GLM


footballData = DataFrame(CSV.File("football_data.csv"))

footballData.difference = footballData.favorite - footballData.underdog
footballData.error = footballData.spread - footballData.difference
  

if false
    plt=plot(footballData,x=:spread,y=:difference,
             Theme(default_color="red",
                   point_size=1pt,
                   background_color="white",
                   highlight_width=0pt),
             Stat.x_jitter(range=0.5),
             Stat.y_jitter(range=0.5),
             Geom.point,
             Coord.Cartesian(xmin=-0.5,xmax=20.5)
             )
    
    #    draw(PDF("spreadVdiff.pdf",8cm,8cm),plt)
    draw(PNG("spreadVdiff.png",16cm,16cm),plt)
end

if true
    footballData.integerSpread=round.(footballData.spread).==footballData.spread

    means = groupby(footballData, :integerSpread)
    means = combine(means, nrow, :error => mean => :mean)

    layer1=layer(footballData,x=:integerSpread,y=:error,Geom.violin)
    layer2=layer(means,x=:integerSpread, y=:mean, shape=[Shape.hline],Geom.point,Theme(default_color="black",point_size=10.0mm));
    plt=plot(layer2,layer1,Theme(background_color="white"))
    
    #    draw(PDF("integerSpread.pdf",8cm,8cm),plt)
    draw(PNG("integerSpread.png",16cm,16cm),plt)

end

if false

    σModel=14.0

    modelResult(spread,σModel) = 0.5+0.5erf(spread /(sqrt(2)*σModel))

    score(a,b) = if (a>b) 1.0 elseif (a<b) 0.0 else 0.5 end

    footballData.win = score.(footballData.favorite,footballData.underdog)

    wins = groupby(footballData, :spread)
    wins = combine(wins,nrow,:win => sum => :totalWin)

    wins.counted = wins.totalWin ./ wins.nrow
    wins.predicted = modelResult.(wins.spread,σModel)

    layer1=layer(wins,x=:spread,y=:predicted,Geom.line)
    layer2=layer(wins,x=:spread,y=:counted,Geom.point)

    plt=plot(layer2,layer1,Theme(background_color="white"))
    #draw(PDF("prediction.pdf",8cm,8cm),plt)
    draw(PNG("prediction.png",16cm,16cm),plt)

    σModel = std(footballData.error)

    wins.predictedNew = modelResult.(wins.spread,σModel)

    layer1b=layer(wins,x=:spread,y=:predictedNew,Geom.line)

    plt=plot(layer2,layer1b,layer1,Theme(background_color="white"))
    #draw(PDF("predictionNewSigma.pdf",8cm,8cm),plt)
    draw(PNG("predictionNewSigma.png",16cm,16cm),plt)

    layer2b=layer(wins,x=:spread,y=:counted,color=:nrow,Geom.point)
    plt=plot(layer2b,layer1,Theme(background_color="white",point_size=5pt))
    draw(PNG("predictionColor.png",16cm,16cm),plt)

    goodCutOff=100
    goodSpread=wins.spread[findall(x -> x>goodCutOff,wins.nrow)]
    isGood(x) = x in goodSpread

    σModel = std(filter(:spread => isGood,footballData).error)

    wins.predictedNew = modelResult.(wins.spread,σModel)

    layer1b=layer(wins,x=:spread,y=:predictedNew,Geom.line,Theme(default_color="red"))

    plt=plot(layer2b,layer1b,layer1,Theme(background_color="white"))
    draw(PNG("predictionGood.png",16cm,16cm),plt)

end

if false

    σs = groupby(footballData,:spread)
    σs = combine(σs, nrow,:error => std => :std)

    plt=plot(σs,x=:spread,y=:std,Geom.point,Theme(default_color="red"))
    #draw(PDF("sigma.pdf",8cm,8cm),plt)
    draw(PNG("sigma.png",16cm,16cm),plt)

end

if true

    fm = @formula(difference ~ spread)
    linearRegressor = lm(fm, footballData)

end
