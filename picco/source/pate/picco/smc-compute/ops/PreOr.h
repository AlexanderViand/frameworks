/*
   PICCO: A General Purpose Compiler for Private Distributed Computation
   ** Copyright (C) 2013 PICCO Team
   ** Department of Computer Science and Engineering, University of Notre Dame

   PICCO is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   PICCO is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with PICCO. If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef PREOR_H_
#define PREOR_H_

#include "Mod2.h"
#include "PrefixMultiplication.h"
#include "Operation.h"

class PreOr: public Operation {
public:
	PreOr(NodeNetwork nodeNet, std::map<std::string, std::vector<int> > poly, int nodeID, SecretShare* s, mpz_t coefficients[]);
	virtual ~PreOr();
	void doOperation(mpz_t** result, mpz_t** A, int K, int size, int threadID);
    
private:
	Mod2 *M2;
	PrefixMultiplication *PreMul;
};

#endif /* PREOR_H_ */