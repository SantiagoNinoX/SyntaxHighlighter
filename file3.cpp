#include <iostream>
#include <string>
using namespace std;

class Monster {
protected:
    float strength;
    string type;
public:
    Monster(string type);
    ~Monster();
    string getType();
    void setType(string type);
    bool isAlive();
};

Monster::Monster(string type) { this->type = type; }
Monster::~Monster() {}
string Monster::getType() { return type; }
void Monster::setType(string type) { this->type = type; }
bool Monster::isAlive() { return strength > 0; }

int main() {
    Monster m('Goblin');
    cout << 'Monster_type' << m.getType() << endl;
    return 0;
}
