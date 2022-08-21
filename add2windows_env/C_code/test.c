unsigned int a[0x40000 + 10] = {9, 8, 10, 0, 0xffffffff};
unsigned int b[0xffff + 10];
unsigned int c[0x40000 + 10];

int bsearchr(int l, int r, unsigned int k)
{
	int mid;
	while (l < r)
	{
		mid = l + r + 1 >> 1;
		if (k >= b[mid])
			l = mid;
		else
			r = mid - 1;
	}
	return l;
}

int main()
{
	int i = 0;
	while (i <= 0xffff)
	{
		b[i] = i * i;
		i++;
	}
	i = 0;
	while (i < 0x40000)
	{
		c[i] = bsearchr(0, 0xffff, a[i]);
		i++;
	}
	return 0;
}