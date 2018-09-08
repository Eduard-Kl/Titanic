function [Train, Test] = drvece

	% Pročitaj datoteke
    [~,~,raw] = xlsread('train.csv');
    Train = cell2table(raw(2:end,:),'VariableNames',raw(1,:));

    [~,~,raw] = xlsread('test.csv');
    Test = cell2table(raw(2:end,:),'VariableNames',raw(1,:));
	
	% Definiranje varijabli	
	Train.Sex = nominal(Train.Sex);
	
	Test.Sex = nominal(Test.Sex);
	
	% Podijeli cabin number u dva dijela
	Train.CabinDeck = cellfun(@(x) x(1),Train.Cabin);
	Train.CabinNum = cellfun(@(x) str2double(strtok(x(2:end))),Train.Cabin);

	Test.CabinDeck = cellfun(@(x) x(1),Test.Cabin);
	Test.CabinNum = cellfun(@(x) str2double(strtok(x(2:end))),Test.Cabin);
	
	% Seed
	rng(123);
	savedRng = rng;
	
	% Naivni pristup
	figure
    gscatter(Train.Age,Train.Sex,Train.Survived)
        set(gca,'YTick',[1 2])
        set(gca,'YTickLabel',{'Female','Male'})
        xlabel('Age')
        ylabel('Sex')
        ylim([0.9 2.1])
        legend({'Deceased','Survived'})
		
		
	% Baseline pristup
	Test.Survived = Test.Age < 16 | Test.Sex == 'female';
	
	baselinePredikcija = table(Test.PassengerId,Test.Survived,'VariableNames',{'PassengerId','Survived'});
	writetable(baselinePredikcija,'Predikcija\BaselinePredikcija.csv')
	
	% Konstrukcija obitelji
	Train.velicinaObitelji = Train.Parch + Train.SibSp + 1;
	Test.velicinaObitelji = Test.Parch + Test.SibSp + 1;	
	
	% Lišće, drveće, random broj
	leaf = 15;
	nTrees = 40;
	rng(savedRng);
	
	
	%-------------------------------------------------------------
	
	
	% Prvi tree bagger
	X = [Train.Sex=='female' Train.Age];
	Xcat = logical([1 0]);
	Y = Train.Survived;

	Xtest = [Test.Sex=='female' Test.Age];
	
	treebagModel = TreeBagger(nTrees,X,Y);	

	% Predikcija
	Ytest = predict(treebagModel,Xtest);
	Ytest = strcmpi(Ytest,'1');
	
	% Rješenje prve predikcije
	predikcija = table(Test.PassengerId,Ytest,'VariableNames',{'PassengerId','Survived'});				
	writetable(predikcija,'Predikcija\PrviRandomForest.csv')
	
	
	%-------------------------------------------------------------
	
	
	% Drugi tree bagger
	X = [Train.Sex=='female' Train.Age Train.Pclass Train.Fare Train.velicinaObitelji double(Train.CabinDeck) Train.CabinNum];
	Y = Train.Survived;

	Xtest = [Test.Sex=='female' Test.Age Test.Pclass Test.Fare Test.velicinaObitelji double(Test.CabinDeck) Test.CabinNum];

	rng(savedRng);
	treebagModel = TreeBagger(nTrees,X,Y);

	% Predikcija
	Ytest = predict(treebagModel,Xtest);
	Ytest = strcmpi(Ytest,'1');

	% Zapis u datoteku
	predikcija = table(Test.PassengerId,Ytest,'VariableNames',{'PassengerId','Survived'});
	writetable(predikcija,'Predikcija\DrugiRandomForest.csv')
end

