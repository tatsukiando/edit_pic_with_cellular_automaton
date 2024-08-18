PImage img;
int[][][] state;
int cellSize = 1;  // 各セルのサイズ
int frameCount = 0;
int imageIndex = 1;
int processingType = 1;  // 1: First processing type, 2: Second, 3: Third, 4: Fourth

void setup() {
  size(2138, 1536);
  loadImageAndInitializeState(imageIndex);
  frameRate(60);  // フレームレートを60fpsに設定
}

void draw() {
  if (frameCount == 0) {
    loadImageAndInitializeState(imageIndex); // Reset image state at the beginning of each processing type
  }
  
  if (processingType == 1) {
    applyFirstProcessing();
  } else if (processingType == 2) {
    applySecondProcessing();
  } else if (processingType == 3) {
    applyThirdProcessing();
  } else if (processingType == 4) {
    applyFourthProcessing();
  }
  
  frameCount++;
  if (frameCount > 300) {
    frameCount = 0;
    processingType++;
    if (processingType > 4) {
      processingType = 1;
      imageIndex++;
      if (imageIndex > 25) {
        noLoop();
        return;
      }
    }
  }
  
  // フレームを画像として保存
  if(frameCount <= 150) {
    int fnum = (imageIndex - 1) * 600 + 150 * (processingType - 1) + frameCount;
    if(fnum>15000){
      saveFrame("output4/" + fnum + ".png");
    }
    else{
      saveFrame("output3/" + fnum + ".png");
    }
  } else if(frameCount <= 225) {
    int fnum = 15000 + (imageIndex - 1) * 300 + 75 * (processingType - 1) + frameCount - 150;
    if(fnum>15000){
      saveFrame("output4/" + fnum + ".png");
    }
    else{
      saveFrame("output3/" + fnum + ".png");
    }
  } else {
    int fnum = 22500 + (imageIndex - 1) * 300 + 75 * (processingType - 1) + frameCount-225;
    if(fnum>15000){
      saveFrame("output4/" + fnum + ".png");
    }
    else{
      saveFrame("output3/" + fnum + ".png");
    }
  }
}

void loadImageAndInitializeState(int index) {
  String imageName = index + ".JPG";
  img = loadImage(imageName);
  img.resize(width, height);
  state = new int[width][height][3];
  
  // 初期状態の設定
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      color c = img.get(x, y);
      state[x][y][0] = int(red(c));
      state[x][y][1] = int(green(c));
      state[x][y][2] = int(blue(c));
    }
  }
}

void applyFirstProcessing() {
  int[][][] newState = new int[width][height][3];
  
  // セルオートマトンのルールを適用
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      for (int c = 0; c < 3; c++) {
        int higherNeighbors = countHigherNeighbors(x, y, c);
        if (higherNeighbors == 2 || higherNeighbors == 3) {
          newState[x][y][c] = (state[x][y][c] + 1) % 256;  // 生存
        } else if (higherNeighbors <= 1) {
          newState[x][y][c] = (state[x][y][c] - 1) % 256;  // 過疎
        } else if (higherNeighbors >= 4) {
          newState[x][y][c] = (state[x][y][c] - 1) % 256;  // 過密
        }
      }
    }
  }
  state = newState;
  
  updatePixelsState();
}

void applyThirdProcessing() {
  int[][][] newState = new int[width][height][3];
  
  // セルオートマトンのルールを適用
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      for (int c = 0; c < 3; c++) {
        int left = getBinaryValue(x - 1, y, c);
        int center = getBinaryValue(x, y, c);
        int right = getBinaryValue(x + 1, y, c);
        int newValue = applyRule110(left, center, right);
        
        // RGB値を更新
        if (newValue != 1) {
          newState[x][y][c] = (state[x][y][c] + 1) % 256;
        } else {
          newState[x][y][c] = (state[x][y][c] - 1) % 256;
        }
      }
    }
  }
  
  state = newState;
  updatePixelsState();
}

void applySecondProcessing() {
  int[][][] newState = new int[width][height][3];
  
  // セルオートマトンのルールを適用
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      for (int c = 0; c < 3; c++) {
        int left = getBinaryValue(x, y - 1, c);
        int center = getBinaryValue(x, y, c);
        int right = getBinaryValue(x, y + 1, c);
        int newValue = applyRule90(left, center, right);
        
        // RGB値を更新
        if (newValue == 1) {
          newState[x][y][c] = (state[x][y][c] + 1) % 256;
        } else {
          newState[x][y][c] = (state[x][y][c] - 1) % 256;
        }
      }
    }
  }
  
  state = newState;
  updatePixelsState();
}

void applyFourthProcessing() {
  int[][][] newState = new int[width][height][3];
  
  // セルオートマトンのルールを適用
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      for (int c = 0; c < 3; c++) {
        int left = getBinaryValue(x - 1, y, c);
        int center = getBinaryValue(x, y, c);
        int right = getBinaryValue(x + 1, y, c);
        int newValue = applyRule30(left, center, right);
        
        // RGB値を更新
        if (newValue == 1) {
          newState[x][y][c] = (state[x][y][c] + 1) % 256;
        } else {
          newState[x][y][c] = (state[x][y][c] - 1) % 256;
        }
      }
    }
  }
  
  state = newState;
  updatePixelsState();
}

void updatePixelsState() {
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int index = x + y * width;
      pixels[index] = color(state[x][y][0], state[x][y][1], state[x][y][2]);
    }
  }
  updatePixels();
}

int countHigherNeighbors(int x, int y, int c) {
  int count = 0;
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx != 0 || dy != 0) {
        int nx = (x + dx + width) % width;
        int ny = (y + dy + height) % height;
        if (state[nx][ny][c] >= state[x][y][c]) {
          count++;
        }
      }
    }
  }
  return count;
}

int getBinaryValue(int x, int y, int c) {
  int wrappedX = (x + width) % width;
  int wrappedY = (y + height) % height;
  return state[wrappedX][wrappedY][c] < 128 ? 0 : 1;
}

int applyRule110(int left, int center, int right) {
  if (left == 1 && center == 1 && right == 1) return 0;
  if (left == 1 && center == 1 && right == 0) return 1;
  if (left == 1 && center == 0 && right == 1) return 1;
  if (left == 1 && center == 0 && right == 0) return 0;
  if (left == 0 && center == 1 && right == 1) return 1;
  if (left == 0 && center == 1 && right == 0) return 1;
  if (left == 0 && center == 0 && right == 1) return 1;
  if (left == 0 && center == 0 && right == 0) return 0;
  return 0;
}

int applyRule90(int left, int center, int right) {
  return left ^ right;
}

int applyRule30(int left, int center, int right) {
  return left ^ (center | right);
}

void keyPressed() {
  if (key == 'q') {
    exit();
  }
}
