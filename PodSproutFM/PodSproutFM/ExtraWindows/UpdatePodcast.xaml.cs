using Oracle.ManagedDataAccess.Client;
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
    /// Логика взаимодействия для UpdatePodcast.xaml
    /// </summary>
    public partial class UpdatePodcast : Window
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";
        Int32 podcastId;
        string narratorNameVal, topicNameVal, oldPodcastName;

        public UpdatePodcast()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
        }

        public UpdatePodcast(Int32 id, string narrator, string topic, string old)
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
            this.podcastId = id;
            this.narratorNameVal = narrator;
            this.topicNameVal = topic;
            this.oldPodcastName = old;
            thisPodcastName.Text = old;
            narratorName.Text = narrator;
            topicName.Text = topic;
        }

        private void AddBtn_Click(object sender, RoutedEventArgs e)
        {
            if (String.IsNullOrWhiteSpace(newPodcastName.Text.Trim()))
            {
                MessageBox.Show("Заполните поле!");
                return;
            }
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.UPDATEPODCASTNAME";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PPODCASTID", OracleDbType.Int16, 10).Value = podcastId;
            cmd.Parameters.Add("PNEWNAME", OracleDbType.Varchar2, 30).Value = newPodcastName.Text.Trim();
            try
            {
                cmd.ExecuteNonQuery();
                MessageBox.Show("Название подкаста успешно обновлено!");
                this.Close();
                Application.Current.Windows[0].Show();
            }
            catch (Exception exc)
            {
                MessageBox.Show("Подкаст с таким названием уже существует!" + exc.Message);
            }
            con.Close();
        }

        private void CloseBtn_Click(object sender, RoutedEventArgs e)
        {
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