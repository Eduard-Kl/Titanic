#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include <vector>
#include <iterator>
#include <algorithm>
#include <boost/algorithm/string.hpp>
#include <cstdlib>

class CSV{
private:
	std::string input;
	std::string delimeter;

public:
	CSV(std::string filename, std::string delm = ";") :
			input(filename), delimeter(delm){}

	std::vector<std::vector<std::string> > getData(){
		std::ifstream file(input);
		if(!file.is_open()){
			std::cout << "Greška prilikom otvaranja datoteke." << std::endl;
			exit(1);
		}

		std::vector<std::vector<std::string> > dataList;
		std::string line = "";

		while (getline(file, line)){
			std::vector<std::string> vec;
			boost::algorithm::split(vec, line, boost::is_any_of(delimeter));
			dataList.push_back(vec);
		}

		file.close();
		return dataList;
	}
};

int main(){

	CSV citacOriginal("gender_submission.csv", ";");
	std::vector<std::vector<std::string> > podaciOriginal = citacOriginal.getData();

	CSV citacPredikcije("prediction.csv", ";");
	std::vector<std::vector<std::string> > podaciPredikcija = citacPredikcije.getData();

	unsigned short int brojacTocnih = 0, brojOsoba = 0;

	for(std::vector<std::string> vecOriginal : podaciOriginal){
		for(std::vector<std::string> vecPredikcija : podaciPredikcija)
			if(vecOriginal[0] == vecPredikcija[0] && vecOriginal[1] == vecPredikcija[1])
				brojacTocnih++;
		brojOsoba++;
	}

	/* -1 za prvi redak */
	std::cout << "Postotak točnosti: " << static_cast<double>(brojacTocnih - 1) / (brojOsoba - 1)  << "." << std::endl;

	return 0;
}