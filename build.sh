#
# Copyright © 2014-2015 myOS Group.
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# Contributor(s):
# Amr Aboelela <amraboelela@gmail.com>
#

echo
echo "****************************** Building frameworks ******************************"

cd Foundation
source build.sh
cd ..

cd CoreFoundation
source build.sh
cd ..

cd CoreGraphics
source build.sh
cd ..

cd CoreText
source build.sh
cd ..

cd IOKit
source build.sh
cd ..

cd OpenGLES
source build.sh
cd ..

cd QuartzCore
source build.sh
cd ..

cd UIKit
source build.sh
cd ..
