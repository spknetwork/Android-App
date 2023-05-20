package tv.threespeak.app

import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Bundle
import android.os.PersistableBundle
import androidx.appcompat.app.AppCompatActivity
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.util.MimeTypes
import tv.threespeak.app.databinding.ActivityVideoPlayerBinding
import java.io.IOException


/**
 * An example full-screen activity that shows and hides the system UI (i.e.
 * status bar and navigation/system bar) with user interaction.
 */
class VideoPlayerActivity : AppCompatActivity() {
    private lateinit var binding: ActivityVideoPlayerBinding
    private var seconds = 0
    private var url = "https://ipfs-3speak.b-cdn.net/ipfs/QmYS9k6LTkbix77XPitT5sGqLKmzfQ9h2qg1ucSwwTFSxx/480p/index.m3u8"

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        initializePlayer()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityVideoPlayerBinding.inflate(layoutInflater)
        setContentView(binding.root)
        intent.extras?.getInt("seconds")?.let {
            this.seconds = it
        }
        intent.extras?.getString("url")?.let {
            this.url = it
        }

            // to go complete full screen
//        WindowCompat.setDecorFitsSystemWindows(window, false)
//        WindowInsetsControllerCompat(window, binding.videoView).let { controller ->
//            controller.hide(WindowInsetsCompat.Type.systemBars())
//            controller.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
//        }
    }

    private var mediaPlayer: MediaPlayer? = null

    private fun initMediaPlayer() {
        mediaPlayer = MediaPlayer()
        mediaPlayer!!.setOnPreparedListener {
            it.start()
        }
        mediaPlayer!!.reset()
        // mediaPlayer!!.setAudioStreamType(AudioManager.STREAM_MUSIC)
        try {
            // Set the data source to the mediaFile location
            mediaPlayer!!.setDataSource(this, Uri.parse(url))
        } catch (e: IOException) {
            e.printStackTrace()
            // stopSelf()
        }
         mediaPlayer!!.prepareAsync()
    }

    private fun initializePlayer() {
        binding.videoView.player = ExoPlayer.Builder(this)
            .build()
            .also { exoPlayer ->

                val mediaItem = MediaItem
                    .Builder()
                    .setUri(url)
                    .setMimeType(MimeTypes.APPLICATION_M3U8)
                    .build()

                exoPlayer.setMediaItem(mediaItem)
                exoPlayer.seekTo((1000 * seconds).toLong())
                exoPlayer.playWhenReady = true
                exoPlayer.prepare()
            }
    }

    public override fun onStart() {
        super.onStart()
        initializePlayer()
//        initMediaPlayer()
    }

    public override fun onStop() {
        super.onStop()
        releasePlayer()
    }

    private fun releasePlayer() {
        binding.videoView.player?.let { exoPlayer ->
            exoPlayer.release()
        }
        binding.videoView.player = null
    }
}