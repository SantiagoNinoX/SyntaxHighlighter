#pragma once
#include <iostream>
#include 'Hola.h'
using namespace std;
class Santi {
public:
	Santi(int edad);
	~Santi();
	int edad;
	int nacer(string nombre, int edad);
	int getEdad();
	void setEdad(int edad);
};

public Santi::Santi(int edad) { edad = edad; }
private Santi :: ~Santi() {}

public int Santi::getEdad() { return edad; }
private int Santi::setEdad(int miEdad) { edad = miEdad; }

public int Santi::nacer(string nombre, int edad) {
	int x;
	x = y;
	int z = x + y;
	int a = b && c;
	x = foo(a, b);
	string invitado;
	cin > > invitado;
	cout << invitado << endl;
	cout << 'Hola_mundo' << endl;
}

Santi* yo, tu;
yo = new Santi(a, b15);

int main() {
	if (a == a) {
		fx(a);
	}
	else if (a > b) {
		c = f(b);
	}
	else {
		fx(a);
	}

	switch (edad) {
	case 1:
		cout << 'Estoy_cansado' << endl;
	case 2:
		int x = 2;
	default:
		cout << 'Default' << endl;
	}

	for (int i = 0; i < 10; i++) {
		cout << 'Hola_mundo' << endl;
	}

	while (variable) {
		cout << 'Hola_mundo' << endl;
		variable = variable + 1;
	}

	do {
		cout << 'Holaa' << endl;
	} while (var);
	return 0;
}