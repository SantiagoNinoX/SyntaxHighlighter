#include <iostream>
#include <string>
using namespace std;

#define PI 3.14
#ifdef DEBUG
#define DEBUG_MODE
#endif

class Room {
private:
    string name;
public:
    Room();
    ~Room();
    string getName();
    void setName(string name);
};

Room::Room() { name = 'Default_Room'; }
Room::~Room() {}
string Room::getName() { return name; }
void Room::setName(string name) { this->name = name; }

int main() {
    Room room;
    room.setName('Dungeon');
    cout << 'Room' << room.getName() << endl;
    return 0;
}
