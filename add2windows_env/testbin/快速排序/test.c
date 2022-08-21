int a[] = {12, 43, 22, 56, 23, 123, 453, 92, 11};

void quicksort(int l, int r)
{
	if (l >= r)
		return;
	int x = a[l + r >> 1], i = l - 1, j = r + 1;
	while (i < j)
	{
		do
			i++;
		while (a[i] < x);
		do
			j--;
		while (a[j] > x);
		if (i < j)
		{
			int t = a[i];
			a[i] = a[j];
			a[j] = t;
		}
	}
	quicksort(l, j);
	quicksort(j + 1, r);
}

int main()
{
	quicksort(0, 8);
	return 0;
}
