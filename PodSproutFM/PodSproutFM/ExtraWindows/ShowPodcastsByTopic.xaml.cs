using Oracle.ManagedDataAccess.Client;
using PodSproutFM.UserControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
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
    /// Логика взаимодействия для ShowPodcastsByTopic.xaml
    /// </summary>
    public partial class ShowPodcastsByTopic : Window
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";
        string narratorVal, topicVal;

        public ShowPodcastsByTopic()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
        }

        public ShowPodcastsByTopic(string narrator, string topic)
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
            this.narratorVal = narrator;
            narratorName.Text = narrator;
            this.topicVal = topic;
            topicName.Text = topic;
        }

        public void LoadTPodcasts()
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHPODCASTBYTOPIC";
                    cmd.CommandType = CommandType.StoredProcedure;
                    string narrator = narratorName.Text.Trim();
                    string topic = topicName.Text.Trim();
                    if (string.IsNullOrEmpty(narrator))
                    {
                        MessageBox.Show("Имя рассказчика не может быть пустым.");
                        return;
                    }
                    cmd.Parameters.Add("PNARRATORNAME", OracleDbType.Varchar2, 30).Value = narrator;
                    cmd.Parameters.Add("PTOPICNAME", OracleDbType.Varchar2, 30).Value = topic;
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        podcastList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            int podcastId = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                            string podcastName = reader.IsDBNull(1) ? "Неизвестно" : reader.GetString(3);
                            string topicName = reader.IsDBNull(2) ? "Неизвестно" : reader.GetString(2);
                            string narratorName = reader.IsDBNull(3) ? "Неизвестно" : reader.GetString(1);
                            int topicYear = reader.IsDBNull(4) ? 0 : reader.GetInt16(4);
                            PodcastUC podcast = new PodcastUC(podcastId, podcastName, topicName, narratorName, (short)topicYear);
                            podcastList.Children.Add(podcast);
                        }
                        if (count == 0)
                        {
                            MessageBox.Show("Нет подкастов для отображения.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке подкастов: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }

        private void CloseBtn_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            LoadTPodcasts();
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