#include <iostream>
#include <string>
using namespace std;

class Player {
private:
    int hp;
    string name;
public:
    Player(int hp);
    ~Player();
    int getHP();
    string getName();
    void setHP(int hp);
    void setName(string name);
    void attack();
};

Player::Player(int hp) { this->hp = hp; }
Player::~Player() {}
int Player::getHP() { return hp; }
string Player::getName() { return name; }
void Player::setHP(int hp) { this->hp = hp; }
void Player::setName(string name) { this->name = name; }
void Player::attack() { 
    cout << name << 'attacking' << hp << endl; 
}

int main() {
    Player p(100);
    p.setName('Omar');
    p.attack();
    return 0;
}
