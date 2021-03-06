//
//  WHHSoudMp3Util.m
//  WoHeiHei
//
//  Created by apple on 14/12/3.
//  Copyright (c) 2014年 ___xmcheng__. All rights reserved.
//

//2014.12.23 zk 增加了一个播放结束的代理方法，以便在各个播放语音的地方对播放停止后进行UI改变
//2015.01.05 zk 修改在播放结束时有个通知没有撤销的错误
//2015.01.15 zk 结束录音后计算片段时间

#import "WHHSoudMp3Util.h"
#import "lame.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation WHHSoudMp3Util
  CGFloat      _sampleRate = 8000.0f;
   int          _bitRate = 8;


- (void) toMp3:(NSString*)filePath
{
   
    
    
    NSString *mp3FilePath = [filePath stringByAppendingString:@".mp3"];
    recordedFile = [NSURL URLWithString:mp3FilePath];
    NSFileManager* deufileManager =  [NSFileManager defaultManager];
    if (![deufileManager fileExistsAtPath:filePath])
    {
        return;
    }
    @try {
        int read, write;
        
        FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, _sampleRate);
//        lame_set_VBR(lame, vbr_default);
        
        lame_set_VBR(lame, vbr_off);
//        lame_set_preset(lame,ABR_8);
//        lame_set_VBR_mean_bitrate_kbps(lame,_bitRate);
//        lame_set_VBR_min_bitrate_kbps(lame,_bitRate);
//        lame_set_VBR_max_bitrate_kbps(lame,_bitRate);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish)
                               withObject:nil
                            waitUntilDone:YES];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        BOOL boolValue=[defaultManager removeItemAtPath: filePath error: nil];
        if (boolValue)
        {
            NSLog(@"remove recorder file ok");
        }
    }
}

- (NSString*)audio_PCMtoMP3:(NSString* )filePath
{
    NSString *cafFilePath = filePath;
    

    NSString *mp3FilePath = [filePath stringByDeletingPathExtension];
    
    mp3FilePath = [mp3FilePath stringByAppendingPathExtension:@"mp3"];
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        NSLog(@"删除");
    }
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
    
    }
    return mp3FilePath;
}


+(NSString*) toMp3Path:(NSString*)filePath
{
    
//    NSString *mp3FilePath = [filePath stringByAppendingString:@".mp3"];
//    recordedFile = [NSURL URLWithString:mp3FilePath];
    
    NSString *mp3FilePath = [filePath stringByDeletingPathExtension];
    
    mp3FilePath = [mp3FilePath stringByAppendingPathExtension:@"mp3"];
    
    NSFileManager* deufileManager =  [NSFileManager defaultManager];
    if (![deufileManager fileExistsAtPath:filePath])
    {
        return nil ;
    }
    @try {
        int read, write;
        
        FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, _sampleRate);
        //        lame_set_VBR(lame, vbr_default);
        
        lame_set_VBR(lame, vbr_off);
        //        lame_set_preset(lame,ABR_8);
        //        lame_set_VBR_mean_bitrate_kbps(lame,_bitRate);
        //        lame_set_VBR_min_bitrate_kbps(lame,_bitRate);
        //        lame_set_VBR_max_bitrate_kbps(lame,_bitRate);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3FinishFile)
                               withObject:nil
                            waitUntilDone:YES];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
//        BOOL boolValue=[defaultManager removeItemAtPath: filePath error: nil];
//        if (boolValue)
//        {
//            NSLog(@"remove recorder file ok");
//        }
    }
    
    return  mp3FilePath;
}

+ (void) convertMp3FinishFile
{
    //    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    //
    //    _alert = [[UIAlertView alloc] init];
    //    [_alert setTitle:@"Finish"];
    //    [_alert setMessage:[NSString stringWithFormat:@"Conversion takes %fs", [[NSDate date] timeIntervalSinceDate:_startDate]]];
    //    [_startDate release];
    //    [_alert addButtonWithTitle:@"OK"];
    //    [_alert setCancelButtonIndex: 0];
    //    [_alert show];
    //    [_alert release];
    
    //    _hasMp3File = YES;
//    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    //    NSInteger fileSize =  [self getFileSize:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", @"Mp3File.mp3"]];
    //    _mp3FileSize.text = [NSString stringWithFormat:@"%d kb", fileSize/1024];
    
    
}

- (void) convertMp3Finish
{
//    [_alert dismissWithClickedButtonIndex:0 animated:YES];
//    
//    _alert = [[UIAlertView alloc] init];
//    [_alert setTitle:@"Finish"];
//    [_alert setMessage:[NSString stringWithFormat:@"Conversion takes %fs", [[NSDate date] timeIntervalSinceDate:_startDate]]];
//    [_startDate release];
//    [_alert addButtonWithTitle:@"OK"];
//    [_alert setCancelButtonIndex: 0];
//    [_alert show];
//    [_alert release];
    
//    _hasMp3File = YES;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//    NSInteger fileSize =  [self getFileSize:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", @"Mp3File.mp3"]];
//    _mp3FileSize.text = [NSString stringWithFormat:@"%d kb", fileSize/1024];
    
    
    NSError *playerError;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedFile
                                                    error:&playerError];
    player.meteringEnabled = YES;
    if (player == nil)
    {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    player.delegate = self;
    _duration = player.duration;
}


-(void)recordeSound:(NSString*)filePath
{

   
//    NSURL* recoderPath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile.caf"]];
    
    NSURL* recoderPath = [NSURL fileURLWithPath:filePath];
    
    NSLog(@" path is %@",recoderPath);
//    [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"];
    session = [AVAudioSession sharedInstance];
    session.delegate = self;
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    /*
     NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
     [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
     [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
     nil];
     */
    //录音设置
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [settings setValue :[NSNumber numberWithFloat:_sampleRate] forKey: AVSampleRateKey];//44100.0
    //通道数
    [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
   // [settings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    
    recorder = [[AVAudioRecorder alloc] initWithURL:recoderPath settings:settings error:nil];
    [recorder prepareToRecord];
    [recorder record];
}

-(void)stopRecorder:(NSString*) filePath
{
    [recorder stop];
    [self toMp3:filePath];
//    [NSThread detachNewThreadSelector:@selector(toMp3:) toTarget:self withObject:filePath];
}

- (void)cancelRecorder:(NSString *)filePath
{
    //停止录音
    [recorder stop];
    //删除文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    BOOL boolValue = [defaultManager removeItemAtPath: filePath error: nil];
    if (boolValue)
    {
        NSLog(@"cancel remove recorder file ok");
    }
}

//filepath  带.mp3后缀
-(void)playMp3:(NSString*) filePath
{
    //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];

    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
   
    if (player!=nil&&[player isPlaying]) {
       
        [player stop];
        [self.delegate playEnd:player.url.path];
        if ( [player.url isEqual:[NSURL URLWithString:filePath]]) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            return;
        }
        
    }
    
    NSError *playerError;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath]
                                                        error:&playerError];
    player.meteringEnabled = YES;
    if (player == nil)
    {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    player.delegate = self;

    [player play];

}

-(void)playOrPause
{
    if  (player.playing) {
        [player pause];
        // if stopped or paused, start playing
    } else  {
        [player play];
    }
}

-(void)stop
{
     if([player isPlaying])
    {
        [player stop];
        [self.delegate playEnd:player.url.path];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    NSLog(@" playing ...... is end...");
    //执行播放结束的delegate
    [self.delegate playEnd:player.url.path];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [playButton setTitle:@"Play" forState:UIControlStateNormal];
}
@end
