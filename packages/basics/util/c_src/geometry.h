/*
 * This file is part of APRIL-ANN toolkit (A
 * Pattern Recognizer In Lua with Artificial Neural Networks).
 *
 * Copyright 2013, Francisco Zamora-Martinez, Salvador España-Boquera, Joan Pastor-Pellicer
 *
 * The APRIL-ANN toolkit is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 */
#ifndef GEOMETRY_H
#define GEOMETRY_H

#include "pair.h"
namespace april_utils {
    typedef pair<float, float> Point2D;

    // TODO: Define Point2D
    class line {

        protected:
            // Slope, y-intercept
            float m, b;

        public:
            line(float m, float b): m(m),b(b){};

            line(const Point2D &, const Point2D &);
            // static line fromPolar(float phi, float r);
            float getSlope() { return m; };
            float getYintercept() { return b; };

            //void getPolars(float &phi, float &r);

            Point2D intersection(const line &, bool &intersect);
            Point2D closestPoint(const Point2D &, float &);
            float distance(const Point2D &);
            //static void polarToRect(float , float , float &, float &);
            //static void rectToPolar(float,  float , float &, float &);
    };

    // TODO: Point/Angle Functions
    // Derivate interest_point Point2D
}

#endif
