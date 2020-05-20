#include <GL/glut.h>
#include <iostream>

#include "x86_function.h" 

using namespace std;

const int P_WIDTH = 800;
const int P_HEIGHT = 800;
const int BPP = 4;
const double ESCAPE_RADIUS = 2;
unsigned char* pPixelBuffer = 0;

double coord_width = 3;
double center_x = P_WIDTH/2.0*1.5, center_y = P_HEIGHT/2.0;

void redraw ()
{
	x86_function(pPixelBuffer, P_WIDTH, P_HEIGHT, coord_width, ESCAPE_RADIUS, center_x, center_y);
	
	glDrawPixels (P_WIDTH, P_HEIGHT, GL_RGBA, GL_UNSIGNED_BYTE, pPixelBuffer);

// copies the back buffer (off-screen buffer) to the front buffer
	glutSwapBuffers ();
}

// handles the mouse click events 
void mouseCallBack (int button, int state, int x, int y)
{
	if (button==GLUT_LEFT_BUTTON && state==0 && (x!=center_x || P_HEIGHT-y!=center_y))
	{
		center_x = (double)x;
		center_y = (double)P_HEIGHT - (double)y;
		redraw ();	
	}
}

// handles key events
void keyboardCallback (unsigned char key, int x, int y)
{
	if (key == 0x20)	// click 'space' to reset
	{
		coord_width = 3;
		center_x = P_WIDTH/2.0*1.5;
		center_y = P_HEIGHT/2.0;
		redraw();
	} 

	if (key == 'i')		//increase
	{
		coord_width/=1.1;
		redraw();
	}
	
	if (key == 'd')		//decrease

	{
		coord_width*=1.1;
		redraw();
	}
}

int main (int argc, char** argv)
{	
	pPixelBuffer = new unsigned char[P_WIDTH*P_HEIGHT*BPP];
	glutInit (&argc, argv);
	
	//with the using of one buffer
	glutInitDisplayMode (GLUT_SINGLE);
	glutInitWindowSize (P_WIDTH, P_HEIGHT);	

	// requests future window to open at a given position
	glutInitWindowPosition (1000, 20);
	glutCreateWindow ("Mandelbrot set");

	// is always called for redrawing the picture		
	glutDisplayFunc (redraw);
	glutMouseFunc (mouseCallBack);	
	glutKeyboardFunc (keyboardCallback);	
	glutMainLoop();
	return 0;
}

