import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

Minim minim;
AudioOutput out; // 出力のオブジェクト
AudioRecorder rec; // ファイル出力のオブジェクト
BandPass bpf1, bpf2; // バンドパスフィルタのオブジェクト
Oscil osc1, osc2; // 音源のオブジェクト
Summer sum; // 複数の音声を加算するオブジェクト
FFT fft;
boolean graphMode = true;
float f1 = 115; // 第1フォルマントの周波数
float f2 = 109; // 第2フォルマントの周波数
float a1 = -22.6; // 第1フォルマントの振幅
float a2 = -43.8; // 第2フォルマントの振幅
float f0 = 115; // 基音の周波数
float bandWidth = 100; // フィルタの通過帯域
float sampleRate = 44100; // 標本化周波数

void setup()
{
  size(1024, 256);
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO);
  osc1 = new Oscil(f0, a1, Waves.SAW); // 音源1のオブジェクト
  osc2 = new Oscil(f0, a2, Waves.SAW); // 音源2のオブジェクト
  bpf1 = new BandPass(f1, bandWidth, sampleRate); // フィルタ1のオブジェクト
  bpf2 = new BandPass(f2, bandWidth, sampleRate); // フィルタ2のオブジェクト 
  sum = new Summer(); // 複数の音声を加算するオブジェクト
  osc1.patch(bpf1).patch(sum); // 音源1をバンドパスフィルタ1を通してsumへ接続する
  osc2.patch(bpf2).patch(sum); // 音源2をバンドパスフィルタ2を通してsumへ接続する
  sum.patch(out); // 加算した音声を出力へ接続する
  fft = new FFT(out.bufferSize(), out.sampleRate()); // スペクトルを計算するオブジェクト
  rec = minim.createRecorder(out, "vowel.wav"); // ファイルへ出力するオブジェクト
}

void keyTyped() {
  switch (key) {
    case 'o': if (!rec.isRecording()) { rec.beginRecord(); } break; // ファイル出力を開始する
    case 'p': if (rec.isRecording()) { rec.endRecord(); } break; // ファイル出力を停止する
    case 'w': graphMode = true; break; // 音声波形を表示する
    case 's': graphMode = false; break; // スペクトルを表示する
    
    case 'a': f0 = 115; f1 = 109; f2 = 3222; a1 = -22.6; a2 = -43.8; out.close(); setup(); break; //「 あ」の音声出力
    case 'i': f0 = 121; f1 = 113; f2 = 3391; a1 = -23.4; a2 = -44.6; out.close(); setup(); break; //「 い」の音声出力
    case 'u': f0 = 110; f1 = 107; f2 = 1855; a1 = -22.9; a2 = -41.8; out.close(); setup(); break; //「 う」の音声出力
    
  }
}

void draw()
{
  background(0); noFill(); stroke(255);
  fft.forward(out.mix);

  // 音声出力のバッファに入っている波形を描画する
  beginShape();
  if (graphMode) {
    stroke(255, 255, 0);
    for (int i = 0; i < out.bufferSize(); i++) {
      float x = map(i, 0, out.bufferSize(), 0, width);
      vertex(x, height * 0.5 + out.mix.get(i) * height * 0.5);
    }
  } else {
    stroke(0, 255, 255);
    for (int i = 0; i < fft.specSize() / 2; i++) { // 
      float x = map(i, 0, fft.specSize(), 0, width * 2.0);
      vertex(x, height - log(1 + fft.getBand(i)) * height / 6.0); // スペクトルを対数軸で表示
    }
  }
  endShape();
}