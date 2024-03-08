#include <iostream>

extern "C" double __stdcall FUNC1(double x); // объ€вл€еем внешнюю функцию

void main() {
	double value;
	std::cout << "Calculating 2sin^2(x)/3\nEnter x:\n";
	std::cin >> value;
	value = FUNC1(value);
	
	if (isnan(value))
		std::cout << "Invalid value of source operand" << std::endl;
	else
		std::cout << "Result:\n" << value << std::endl;
}