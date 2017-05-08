from math import factorial
import numpy as np

class Combination(object):
    # Return potential number of combinations between two numbers
    def __init__(self, n=0, h=0, i=0, j=0):
        self.n = n
        self.h = h
        self.i = i
        self.j = j

    def combination(self):
        numerator=factorial(self.n)
        denominator=(factorial(self.h)*factorial(self.n - self.h))
        answer=numerator/denominator
        return answer


    def column_ids(self):
        col = np.zeros((self.n, 1))
        for j in range(self.n):
            if self.i <= self.h*2:
                if j == 0:
                    col[j,0] = 1
                elif self.i + j == self.h:
                    col[j,0] = 1
                else:
                    col[j,0] = 0

        return col
        
