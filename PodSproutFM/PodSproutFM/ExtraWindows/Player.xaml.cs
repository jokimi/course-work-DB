using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace PodSproutFM.ExtraWindows
{
    /// <summary>
    /// Логика взаимодействия для Player.xaml
    /// </summary>
    public partial class Player : Window
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=jokimi;DBA PRIVILEGE=SYSDBA";
        Int32 podcastId, topicId;
        string narratorNameVal, topicNameVal, podcastNameVal;
        byte[] audioByteArr;
        MediaPlayer mediaPlayerObj = new MediaPlayer();

        public Player()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.GETPODCASTAUDIO";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PPODCASTID", OracleDbType.Int32).Value = podcastId.ToString();
            OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
            cursorParam.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(cursorParam);
            OracleDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                try
                {
                    audioByteArr = reader.GetValue(0) as byte[];
                    using (FileStream bytesToAudio = File.Create("current.mp3"))
                    {
                        bytesToAudio.Write(audioByteArr, 0, audioByteArr.Length);
                        Stream audioFile = bytesToAudio;
                        bytesToAudio.Close();
                    }
                    mediaPlayerObj.Open(new Uri(@"D:\BSTU\Projects\БД\PodSproutFM\PodSproutFM\bin\Debug\current.mp3"));
                }
                catch (Exception exc)
                {
                    MessageBox.Show(exc.Message);
                }
            }
        }

        private void PlayButton_Click(object sender, RoutedEventArgs e)
        {
            mediaPlayerObj.Play();
        }

        private void PauseButton_Click(object sender, RoutedEventArgs e)
        {
            mediaPlayerObj.Pause();
        }

        private void StopButton_Click(object sender, RoutedEventArgs e)
        {
            mediaPlayerObj.Stop();
        }

        public Player(Int32 id, string narrator, string topic, string podcast)
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
            this.podcastId = id;
            this.narratorNameVal = narrator;
            this.topicNameVal = topic;
            this.podcastNameVal = podcast;
            narratorName.Text = narrator;
            topicName.Text = topic;
            podcastName.Text = podcast;
        }

        private void CloseBtn_Click(object sender, RoutedEventArgs e)
        {
            mediaPlayerObj.Close();
            this.Close();
            Application.Current.Windows[0].Show();
        }
        private void BtnClose_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }
        private void BtnMinimize_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }
    }
}