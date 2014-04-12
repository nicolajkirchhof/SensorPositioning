#include <boost/range.hpp>


template<class T, unsigned int n, unsigned int m> struct my_range {
	T	value[n][m];
	unsigned int N;
	unsigned int M;
	inline T& operator[] (const unsigned int n, const unsigned int m)
	{
		return value[n][m];
	}
    inline T& operator[] (const unsigned int n, const unsigned int m)
	{
		return value[n][m];
	}

};

int main(int argc, const char* argv[])
{
	typedef my_range<double, 2, 4> double_range;
	double_range dr;

	return 0;

}