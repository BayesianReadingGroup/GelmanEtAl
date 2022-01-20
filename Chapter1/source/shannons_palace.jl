
function makeBayes(pLGivenR::Float64,pLGivenNotR::Float64)
    function bayes(pR::Float64,result::Char)
        
        pResultGivenR = (result=='L') ? pLGivenR : 1.0-pLGivenR
        pResultGivenNotR = (result=='L') ? pLGivenNotR : 1.0-pLGivenNotR

        pL=pResultGivenR*pR+pResultGivenNotR*(1-pR)

        pResultGivenR*pR/pL

    end
end

pLGivenR=0.8
pLGivenNotR=0.9

bayes=makeBayes(pLGivenR,pLGivenNotR)

pR=0.5

resultSequence="LW"

for i in length(resultSequence):-1:1
    println(i," ",resultSequence[i])
    global pR
    pR=bayes(pR,resultSequence[i])
    println(pR)
end
             
    

    
