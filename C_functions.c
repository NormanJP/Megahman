#include <stdio.h>

void drawPixel(int x, int y, short colr)
{
	volatile short *VGAaddress = (volatile short*)(0x08000000 + (y<<10) + (x<<1));
	*VGAaddress = colr;
}

void removeScreen (int mX, int mY, int sX, int sY) //refresh megaman and his bullet
{
	int x, y;
	
	removeMegaman(mX, mY); //clear megaman
	clearPreviousShot (sX, sY); //clear shot
	
	return;
}



void clearScreen() //clear entire screen
{
	int x, y;
	for (x = 0; x < 320; x++){
		for (y = 0; y < 240; y++){
			drawPixel(x, y, 0XF800);
		
		}
	}	
	return;
}

void drawLevel (volatile short* lvl)
{
	
	int x, y;
	volatile short *temp = lvl;
	
	for (y = 0; y < 190; y++){
		for (x = 0; x < 320; x++){
			drawPixel(x, y, *temp); //Draw the corresponding colour of the shot
			temp = temp + 1; //get the next colour
		}
	}
	return;
}

void drawToWholeScreen (volatile short* lvl)
{
	
	int x, y;
	volatile short *temp = lvl;
	
	for (y = 0; y < 240; y++){
		for (x = 0; x < 320; x++){
			drawPixel(x, y, *temp); //Draw the corresponding colour of the shot
			temp = temp + 1; //get the next colour
		}
	}
	return;
}


void showAdress (volatile short* adr)
{
	printf("Key pressed :) \n");
	
	return;
}

void drawShotRight(int x_, int y_, volatile short *shotAddress)
{
	int x, y;
	volatile short *temp = shotAddress;
	
	for (y = y_; y < y_+7; y++){
		for (x = x_; x < x_+8; x++){
			if (*temp != 0XFFFFFFFF){
				drawPixel(x, y, *temp); //Draw the corresponding colour of the shot
			}
			temp = temp + 1; //get the next colour
		}
	}

}

void drawShotLeft(int x_, int y_, volatile short *shotAddress)
{
	int x, y;
	volatile short *temp = shotAddress;
	
	for (y = y_; y < y_+7; y++){
		for (x = x_+7; x >= x_; x--){
			if (*temp != 0xFFFFFFFF){
				drawPixel(x, y, *temp); //Draw the corresponding colour of the shot
			}
			temp = temp + 1; //get the next colour
		}
	}

}


void removeMegaman(int x_, int y_, volatile short* bg) //get rid of the last megaman
{
	int x, y;
	volatile short* temp = bg;
	
	for (y = y_-23; y <= y_; y++){ // "y_" is a variable storing the bottom of the picture (big value)
		temp = bg + y*320; //get the row
		for (x = x_; x <= x_+30; x++){ //x stores the left of the picture (small value)
			temp = temp + x;
			drawPixel(x, y, *temp); //Draw the corresponding colour of standing Megaman
			temp = temp - x;
		}
	}
	return;
}

void removeMegamanJumping(int x_, int y_, volatile short* adr) //get rid of the last megaman
{
	int x, y;
	volatile short* temp; //create a temporary pointer


	for (y = y_-35; y <= y_; y++){ // "y_" is a variable storing the bottom of the picture (big value)
		temp = adr + y*320;
		for (x = x_; x <= x_+27; x++){ //x stores the left of the picture (small value)
			temp = temp + x;
				drawPixel(x, y, *temp); //Draw the corresponding colour of standing Megaman
			temp = temp - x;
		}
	}
	return;
}

void clearPreviousShot (int x_, int y_, volatile short* bg) //get rid of the last shot
{
	int x, y;
	
	volatile short* temp;
	for (y = y_; y < y_+7; y++){
		temp = bg + y*320;
		for (x = x_; x < x_+8; x++){
			temp = temp + x;
			drawPixel(x, y, *temp); //Change this to clearing the BG colour
			temp = temp - x;
		}
	}
	return;
}

void drawStandingRight (int x_, int y_, volatile short* standAddress)
{
	int x, y;
	volatile short* temp = standAddress;
	for (y = y_-23; y <= y_; y++){ // "y_" is a variable storing the bottom of the picture (big value)
		for (x = x_; x <= x_+30; x++){ //x stores the left of the picture (small value)
			if (*temp != 0xFFFFFFFF){
				drawPixel(x, y, *temp); //Draw the corresponding colour of standing Megaman
			}
			temp = temp + 1; //get the next colour
		}
	}
	return;
}



void drawStandingLeft(int x_, int y_, volatile short* standAddress)
{
	int x, y;
	volatile short* temp = standAddress; // hold address in temporary pointer
	
	for (y = y_-23; y <= y_; y++){
		for (x = x_+30; x >= (x_); x--){
			if (*temp != 0xFFFFFFFF){
				drawPixel(x, y, *temp); //Draw the corresponding colour of standing Megaman
			}
			temp = temp + 1; //get the next colour
		}
	}
}

void drawWalkingRight (int x_, int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-21; y <= y_; y++){
		for (x = x_; x < x_ + 29; x++){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	

void drawWalkingLeft (int x_, int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-21; y <= y_; y++){
		for (x = x_+28; x >= x_; x--){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	

void drawWalkingRight2 (int x_, int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-23; y <= y_; y++){
		for (x = x_; x < x_ + 26; x++){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	

void drawWalkingLeft2 (int x_, int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-23; y <= y_; y++){
		for (x = x_+25; x >= x_; x--){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	

void drawWalkingRight3 (int x_, int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-21; y <= y_; y++){
		for (x = x_; x < x_ + 30; x++){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	


void drawWalkingLeft3 (int x_, int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-21; y <= y_; y++){
		for (x = x_+29; x >= x_; x--){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	

void drawJumpingRight (int x_, int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-29; y <= y_; y++){
		for (x = x_; x <= x_+27; x++){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	

void drawJumpingLeft (int x_, int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-29; y <= y_; y++){
		for (x = x_+27; x >= x_; x--){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	


void drawEnemy (int x_ ,int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-23; y <= y_; y++){
		for (x = x_; x < x_+32; x++){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	

void drawEnemyThrowing (int x_,int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-23; y <= y_; y++){
		for (x = x_; x <= x_+22; x++){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	

void removeEnemy(int x_, int y_, volatile short* bg) //get rid of the last megaman
{
	int x, y;
	volatile short* temp = bg;
	
	for (y = y_-23; y <= y_; y++){ // "y_" is a variable storing the bottom of the picture (big value)
		temp = bg + y*320; //get the row
		for (x = x_; x <= x_+31; x++){ //x stores the left of the picture (small value)
			temp = temp + x;
			drawPixel(x, y, *temp); //Draw the corresponding colour of standing Megaman
			temp = temp - x;
		}
	}
	return;
}

void drawAxe (int x_ ,int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-10; y <= y_; y++){
		for (x = x_; x < x_+12; x++){
			if (*temp != 0xFFFFFFFF ){ //check for eyes
				drawPixel (x, y, *temp);
			}
			temp = temp + 1;
		}
	}

	return;
}	

void removeEnemyProjectile(int x_, int y_, volatile short* bg) //get rid of the last megaman
{
	int x, y;
	volatile short* temp = bg;
	
	for (y = y_-10; y <= y_; y++){ // "y_" is a variable storing the bottom of the picture (big value)
		temp = bg + y*320; //get the row
		for (x = x_; x <= x_+11; x++){ //x stores the left of the picture (small value)
			temp = temp + x;
			drawPixel(x, y, *temp); //Draw the corresponding colour of standing Megaman
			temp = temp - x;
		}
	}
	return;
}

void drawHairFlow (int x_,int y_, volatile short* adr)
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = y_-23; y <= y_; y++){
		for (x = x_; x <= x_+20; x++){
				drawPixel (x, y, *temp);
			temp = temp + 1;
		}
	}

	return;
}	


void drawTheHUD (volatile short* adr) //draws the hud at the bottom of the screen
{
	volatile short *temp = adr;
	int x, y;
	
	for (y = 190; y <= 239; y++){
		for (x = 0; x <= 319; x++){
				drawPixel (x, y, *temp);
			temp = temp + 1;
		}
	}

	return;
}	