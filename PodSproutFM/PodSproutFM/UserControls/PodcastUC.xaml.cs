using Oracle.ManagedDataAccess.Client;
using PodSproutFM.ExtraWindows;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace PodSproutFM.UserControls
{
    /// <summary>
    /// Логика взаимодействия для PodcastUC.xaml
    /// </summary>
    public partial class PodcastUC : UserControl
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";
        Int32 year, podcastId;
        string podcast, topic, narrator;
        byte[] cover, audio;

        private void PlayPodcast_Click(object sender, RoutedEventArgs e)
        {
            Player play = new Player(this.podcastId, this.narrator, this.topic, this.podcast);
            play.Show();
            Application.Current.Windows[0].Hide();
        }

        private void DeletePodcast_Click(object sender, RoutedEventArgs e)
        {
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Вы уверены, что хотите удалить этот подкаст?", "Удаление подкаста", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.DELETEPODCAST";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("PID", OracleDbType.Int32, 10).Value = podcastId;
                try
                {
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Подкаст успешно удален!");
                }
                catch (OracleException ex)
                {
                    MessageBox.Show("Ошибка при удалении подкаста!" + ex.Message);
                }
                con.Close();
            }
        }

        private void SavePodcast_Click(object sender, RoutedEventArgs e)
        {
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Хотите добавить подкаст в избранное?", "Добавление в избранное", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult != MessageBoxResult.Yes) return;
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.SAVEPODCAST";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PUSERID", OracleDbType.Int32, 10).Value = DataWorker.CurrentUserId;
            cmd.Parameters.Add("PPODCASTID", OracleDbType.Int32, 10).Value = podcastId;
            try
            {
                cmd.ExecuteNonQuery();
                MessageBox.Show("Подкаст успешно сохранён в избранное!");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при добавлении подкаста в избранное!");
            }
            con.Close();
        }

        private void EditPodcast_Click(object sender, RoutedEventArgs e)
        {
            UpdatePodcast updateWin = new UpdatePodcast(this.podcastId, this.narrator, this.topic, this.podcast);
            updateWin.Show();
            Application.Current.Windows[0].Hide();
        }

        private void CheckRole()
        {
            if (DataWorker.CurrentUserRole == "ADMIN")
            {
                adminButtons.Visibility = Visibility.Visible;
                return;
            }
            else return;
        }

        public PodcastUC()
        {
            InitializeComponent();
            CheckRole();
            con.ConnectionString = connectionString;
        }

        public PodcastUC(Int32 id, string narratorName, string topicName, string podcastName, Int16 yearReleased)
        {
            con.ConnectionString = connectionString;
            InitializeComponent();
            CheckRole();
            this.podcastId = id;
            this.narrator = narratorName;
            this.topic = topicName;
            this.podcast = podcastName;
            this.year = yearReleased;

            blockNarratorName.Text = narratorName;
            blockTopicName.Text = topicName;
            blockPodcastName.Text = podcastName;
            blockYear.Text = yearReleased.ToString();

            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.GETPODCASTBLOB";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PPODCASTID", OracleDbType.Int32).Value = id.ToString();
            OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
            cursorParam.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(cursorParam);
            OracleDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                try
                {
                    BitmapImage image = new BitmapImage();
                    image.BeginInit();
                    cover = reader.GetValue(0) as byte[];
                    image.StreamSource = new MemoryStream(reader.GetValue(0) as byte[]);
                    image.EndInit();
                    topicCover.Source = image;
                }
                catch (Exception exc)
                {
                    MessageBox.Show(exc.Message);
                }
            }
            con.Close();
        }
    }
}