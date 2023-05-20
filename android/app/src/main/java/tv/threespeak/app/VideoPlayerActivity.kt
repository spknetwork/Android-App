package tv.threespeak.app

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.PersistableBundle
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.util.MimeTypes
import tv.threespeak.app.databinding.ActivityVideoPlayerBinding

/**
 * An example full-screen activity that shows and hides the system UI (i.e.
 * status bar and navigation/system bar) with user interaction.
 */
class VideoPlayerActivity : AppCompatActivity() {
    private lateinit var binding: ActivityVideoPlayerBinding

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        initializePlayer()
    }

//    private var player: ExoPlayer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityVideoPlayerBinding.inflate(layoutInflater)
        setContentView(binding.root)
    }

    private fun initializePlayer() {
        binding.videoView.player = ExoPlayer.Builder(this)
            .build()
            .also { exoPlayer ->
                val mediaItem = MediaItem
                    .Builder()
                    .setUri("https://ipfs-3speak.b-cdn.net/ipfs/QmYS9k6LTkbix77XPitT5sGqLKmzfQ9h2qg1ucSwwTFSxx/480p/index.m3u8")
                    .setMimeType(MimeTypes.APPLICATION_M3U8)
                    .build()

                exoPlayer.setMediaItem(mediaItem)
                exoPlayer.playWhenReady = true
                exoPlayer.prepare()
            }
    }

    public override fun onStart() {
        super.onStart()
        initializePlayer()
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