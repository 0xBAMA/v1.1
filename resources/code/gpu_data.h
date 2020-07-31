#ifndef GPU_DATA
#define GPU_DATA

#include "includes.h"

class GLContainer
{
    public:

        GLContainer()  {}
        ~GLContainer() {}


        // initialization
        void init() { compile_shaders(); buffer_geometry(); load_textures(); }

        // display function
        bool show_widget = true;
        void display() { display_block(); if(show_widget) display_orientation_widget(); }

        // manipulating the block
        void swap_blocks();



// Shapes
        // aabb
        // sphere
        // cylinder
        // tube
        // cuboid
        // triangle
        // grid
        // ellipsoid
        // heightmap
        // perlin noise



// GPU-side utilities
        // clear all
        // unmask all
        // invert mask
        // mask by color
        // blur
        // shifting



// Lighting
        // lighting clear (to cached level)
        // directional
        // ambient occlusion
        // fake GI
        // mash (combine light into color buffer)



// CPU-side utilities
        // functions to generate new heightmaps & buffer them to the GPU
        void generate_heightmap_diamond_square();
        void generate_heightmap_perlin();
        void generate_heightmap_XOR();

        // generate 3d perlin noise & buffer to the GPU
        void generate_perlin_noise(float xscale, float yscale, float zscale);

        // Brent Werness's Voxel Automata Terrain - need a respect_mask toggle
        std::string vat(float flip, std::string rule, int initmode, glm::vec4 color0, glm::vec4 color1, glm::vec4 color2, float lambda, float beta, float mag);

        // load - need to add respect_mask toggle
        void load(std::string filename);

        // save
        void save(std::string filename);




        // OpenGL clear color
        glm::vec4 clear_color;

        // display parameters - public so they can be manipulated
        float scale = 5.0f, theta = 0.0f, phi = 0.0f;

        unsigned int screen_width, screen_height;

    private:

        // display helper functions
        void display_block();
        void display_orientation_widget();

        // init helper functions
        void compile_shaders();
        void buffer_geometry();
        void load_textures();

        // helper function for buffer_geometry (used to generate the orientation widget)
        void cube_geometry(glm::vec3 a, glm::vec3 b, glm::vec3 c, glm::vec3 d, glm::vec3 e, glm::vec3 f, glm::vec3 g, glm::vec3 h, std::vector<glm::vec3> &points, std::vector<glm::vec3> &normals, std::vector<glm::vec3> &colors, glm::vec3 color);

    // The texture breakdown is as follows:
    //  0  - main block render texture
    //  1  - copy/paste buffer's render texture
    //  2  - main block front color buffer
    //  3  - main block back color buffer
    //  4  - main block front mask buffer
    //  5  - main block back mask buffer
    //  6  - display lighting buffer
    //  7  - lighting cache buffer
    //  8  - copy/paste front buffer
    //  9  - copy/paste back buffer
    //  10 - load buffer (used for load, Voxel Automata Terrain)
    //  11 - perlin noise
    //  12 - heightmap
        GLuint textures[13];

        // shows the texture containing the rendered block - workgroup is 32x32x1
        GLuint display_compute_shader;   // raycast -> texture
        GLuint display_shader;           // texture -> window
        GLuint display_vao;
        GLuint display_vbo;

        // shows where x, y and z are pointing
        GLuint orientation_widget_shader;   // shows the orientation widget
        GLuint orientation_widget_vao;
        GLuint orientation_widget_vbo;

        // compute shaders
        // GLuint ...

};

#endif
