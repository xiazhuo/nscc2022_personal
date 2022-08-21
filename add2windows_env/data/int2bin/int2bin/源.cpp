// This program uses the write and read functions.
#include <iostream>
#include <fstream>
using namespace std;
int main()
{
	// File object used to access file
	fstream file("data.bin", ios::out | ios::binary);
	if (!file)
	{
		cout << "Error opening file.";
		return 0;
	}
	// Integer data to write to binary file
	int buffer[] = { 12,43,22,56,23,123,453,92,11,0 };
	int size = sizeof(buffer) / sizeof(buffer[0]);
	// Write the data and close the file
	file.write(reinterpret_cast<char*>(buffer), sizeof(buffer));
	file.close();
	cout << "Writing finished!\n";
	return 0;
}