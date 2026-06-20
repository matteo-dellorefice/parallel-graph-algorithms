
#include <GL/glew.h>
#include <GL/freeglut.h>


#include <vector>
#include <sstream>
#include <chrono>
#include <cstddef>
#include <random>
#include <eigen3/Eigen/Dense>

#include "pgra/pgra.hpp"


struct Vertex
{
    Eigen::Vector4f pos;
    Eigen::Vector4f color;

    static Vertex random(std::uniform_real_distribution<float>& dist, std::mt19937& rng) {
        return {
            Eigen::Vector4f(dist(rng), dist(rng), dist(rng), 1.0),
            Eigen::Vector4f(dist(rng), dist(rng), dist(rng), 1.0)
        };
    }
};

pgra::device_graph_csr graphpgra = pgra::device_graph_csr::create_random(time(NULL), 100000, 0.001);
std::vector<Vertex> verts;
GLuint vbo = 0;

void init()
{
    // init geometry
    std::random_device rd;
    std::mt19937 rng(rd());
    std::uniform_real_distribution<float> dist(0, 1);
    for( size_t i = 0; i < 1000000; i++ )
    {
        Vertex vert = Vertex::random(dist, rng);
        verts.push_back(vert);
    }

    // create VBO
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * verts.size(), verts.data(), GL_STATIC_DRAW);
}

void display()
{
    // timekeeping
    static std::chrono::steady_clock::time_point prv = std::chrono::steady_clock::now();
    std::chrono::steady_clock::time_point cur = std::chrono::steady_clock::now();
    const float dt = std::chrono::duration<float>(cur - prv).count();
    prv = cur;

    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    double w = glutGet(GLUT_WINDOW_WIDTH);
    double h = glutGet(GLUT_WINDOW_HEIGHT);
    gluPerspective(60.0, w / h, 0.1, 10.0);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(2, 2, 2, 0, 0, 0, 0, 0, 1);

    static float angle = 0.0f;
    angle += dt * 6.0f;
    glRotatef(angle, 0, 0, 1);

    // render VBO
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glVertexPointer(4, GL_FLOAT, sizeof(Vertex), (void*)offsetof(Vertex, pos));
    glColorPointer(4, GL_FLOAT, sizeof(Vertex), (void*)offsetof(Vertex, color));
    glDrawArrays(GL_POINTS, 0, verts.size());
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    // info/frame time output
    std::stringstream msg;
    msg << "Frame time: " << (dt * 1000.0f) << " ms";
    glColor3ub(255, 255, 0);
    glWindowPos2i(10, 25);
    glutBitmapString(GLUT_BITMAP_9_BY_15, (unsigned const char*)(msg.str().c_str()));

    glutSwapBuffers();
}

int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
    glutInitWindowSize(600, 600);
    glutCreateWindow("GLUT");
    glewInit();
    init();
    glutDisplayFunc(display);
    glutIdleFunc(display);
    glutMainLoop();
    return 0;
}