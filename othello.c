#include <stdio.h>

#define GRID_X 8
#define GRID_Y 8

int board[64];
int score[2];
int turn = 1;
char player[3];

int get(int x,int y)
{
	return (x*8 + y);
}

int check_bound(int x,int y)
{
	if(x < 0 || y < 0 || x > 7 || y > 7)
	{
		return 0;
	}
	return 1;
}

void print_board()
{
	int i=0,j=0;
	printf("   "); //3 spaces
	for(i=1;i<=8;i++)
	{
		printf("%3d",i);
	}
	printf("\n");
	for(i=0;i<8;i++)
	{
		printf("%3d",i+1);
		for(j=0;j<8;j++)
		{
			printf("  %c",player[board[get(i,j)]]);
		}
		printf("\n");
	}
	printf("\n\n");
	printf("Player %c => %d\nPlayer %c => %d\n",player[1],score[0],player[2],score[1]);
}

int check(int player)
{
	int isPossible = 0;
	int original_turn = turn;
	int i=0,j=0;
	turn = player;
	for(i=0;(i<8)&&(isPossible == 0);i++)
	{
		for(j=0;(j<8)&& (isPossible == 0);j++)
		{
			if(board[get(i,j)] == 0)
			{
				isPossible = move(i,j,0);
			}
		}
	}
	turn = original_turn;
	return isPossible;
}
int check_valid(int i,int j)
{
	if(!check_bound(i,j) || board[get(i,j)] == turn)
	{
		return 0;
	}
	return 1;
}
int move(int i,int j, int set)
{
	int ans = 0;
	if(check_valid(i-1,j))
	{
		ans += recurse_turn(i-1,j,-1,0,set);
	}
	if(check_valid(i+1,j))
	{
		ans += recurse_turn(i+1,j,1,0,set);
	}
	if(check_valid(i,j-1))
	{
		ans += recurse_turn(i,j-1,0,-1,set);
	}
	if(check_valid(i,j+1))
	{
		ans += recurse_turn(i,j+1,0,1,set);
	}
	if(check_valid(i+1,j+1))
	{
		ans += recurse_turn(i+1,j+1,1,1,set);
	}
	if(check_valid(i-1,j-1))
	{
		ans += recurse_turn(i-1,j-1,-1,-1,set);
	}
	if(check_valid(i+1,j-1))
	{
		ans += recurse_turn(i+1,j-1,1,-1,set);
	}
	if(check_valid(i-1,j+1))
	{
		ans += recurse_turn(i-1,j+1,-1,1,set);
	}
	return ans;
}

int play(int x, int y)
{
	x--;y--;
	if(!check_bound(x,y) || board[get(x,y)] != 0)
	{
		return 0;
	}
	int isValid = 0;
	int i=0,j=0;
	isValid = move(x,y,1);
	if(isValid == 0)
	{
		return 0;
	}

	int next_turn = (turn % 2)+1;
	board[get(x,y)] = turn;
	score[turn-1]++;
	// printf("Move Made\n");
	if(check(next_turn))
	{
		turn = next_turn;
		return next_turn;
	}
	else if(check(turn))
	{
		printf("Not possible for new turn\n");
		return turn;
	}
	else
	{
		return -1;
	}
}

int recurse_turn(int x,int y, int inc_x, int inc_y, int set)
{
	if(!check_bound(x,y) || board[get(x,y)] == 0)
	{
		return 0;
	}
	if(board[get(x,y)] == turn)
	{
		return 1;
	}
	int ans = recurse_turn(x+inc_x,y+inc_y,inc_x,inc_y,set);
	if(ans == 1)
	{
		if(set == 1)
		{
			board[get(x,y)] = turn;
			score[turn-1]++;
			score[(turn%2)]--;
		}
		return 1;
	}
	else
	{
		return 0;
	}
}

int main()
{
	int end = 0;
	int x=0,y = 0;
	board[get(3,3)] = 1;
	board[get(4,4)] = 1;
	board[get(3,4)] = 2;
	board[get(4,3)] = 2;
	player[0] = '-';
	player[1] = '#';
	player[2] = '0';
	score[0] = 2;
	score[1] = 2;
	printf("\e[1;1H\e[2J");

	while(end == 0)
	{
		print_board();
		printf("\nTurn of player: %c\nMove : ",player[turn]);
		scanf("%d %d",&x,&y);
		printf("\e[1;1H\e[2J");
		int ret = play(x,y);
		if(ret == 0)
		{
			printf("\nPlease Enter a valid move!\n\n");
		}
		else if(ret == -1)
		{
			printf("Game End!\n");
			end = 1;
		}
	}
	return 0;
}