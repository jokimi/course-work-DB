using Oracle.ManagedDataAccess.Client;
using PodSproutFM.ExtraWindows;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
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
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace PodSproutFM.UserControls
{
    /// <summary>
    /// Логика взаимодействия для TopicUC.xaml
    /// </summary>
    public partial class TopicUC : UserControl
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";
        Int16 year, topicId;
        string topic, narrator;
        byte[] cover;

        private void CheckRole()
        {
            if (DataWorker.CurrentUserRole == "ADMIN")
            {
                adminButtons.Visibility = Visibility.Visible;
                return;
            }
            else return;
        }

        private void EditTopic_Click(object sender, RoutedEventArgs e)
        {
            UpdateTopic updateWin = new UpdateTopic(this.topicId, this.narrator, this.topic);
            updateWin.Show();
            Application.Current.Windows[0].Hide();
        }

        private void DeleteTopic_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                MessageBoxResult result = MessageBox.Show("Вы уверены, что хотите удалить тему?", "Подтверждение удаления", MessageBoxButton.YesNo);
                if (result == MessageBoxResult.Yes)
                {
                    OracleCommand cmd = con.CreateCommand();
                    cmd.CommandText = "SYS.DELETETOPIC";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("PID", OracleDbType.Int32).Value = this.topicId;
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Тема успешно удалена!");
                    this.Visibility = Visibility.Collapsed;
                }
            }
            catch (OracleException ex)
            {
                if (ex.Number == -20009)
                {
                    MessageBox.Show("Тема не найдена!");
                }
                else if (ex.Number == -20010)
                {
                    MessageBox.Show("Ошибка: Не удалось найти данные для удаления.");
                }
                else
                {
                    MessageBox.Show("Ошибка при удалении: " + ex.Message);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Произошла ошибка: " + ex.Message);
            }
        }

        private void ShowPodcasts_Click(object sender, RoutedEventArgs e)
        {
            ShowPodcastsByTopic show = new ShowPodcastsByTopic(narrator, topic);
            show.Show();
            Application.Current.Windows[0].Hide();
        }

        public TopicUC()
        {
            InitializeComponent();
            CheckRole();
            con.ConnectionString = connectionString;
        }

        public TopicUC(Int16 id, string narratorName, string topicName, Int16 yearReleased)
        {
            con.ConnectionString = connectionString;
            InitializeComponent();
            CheckRole();
            this.topicId = id;
            this.topic = topicName;
            this.narrator = narratorName;
            this.year = yearReleased;

            blockTopicName.Text = topicName;
            blockNarratorName.Text = narratorName;
            blockYear.Text = yearReleased.ToString();

            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.GETTOPICBLOB";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PTOPICID", OracleDbType.Int32).Value = id.ToString();
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
                    image.StreamSource = new MemoryStream(reader.GetValue(0) as byte[]);
                    image.EndInit();
                    topicCover.Source = image;
                }
                catch (Exception exc)
                {
                    MessageBox.Show(exc.Message);
                }
            }
        }
    }
}