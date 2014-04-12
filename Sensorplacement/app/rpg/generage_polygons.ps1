for ($count = 10; $count -le 10000; $count = $count * 10)
{
	./rpg-2.0.exe --noX --random $count --algo 2opt --format poly --output poly$count --count 1000
	echo $count
}