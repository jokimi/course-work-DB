using Microsoft.Win32;
using Oracle.ManagedDataAccess.Client;
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
using System.Windows.Shapes;

namespace PodSproutFM.ExtraWindows
{
    /// <summary>
    /// Логика взаимодействия для AddNewPodcast.xaml
    /// </summary>
    public partial class AddNewPodcast : Window
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=jokimi;DBA PRIVILEGE=SYSDBA";

        Int32 podcastId;
        string narrator, topic, podcast;
        byte[] audio;
        string audioName;

        public event Action PodcastAdded;

        public void NarratorComboBox(OracleConnection con)
        {
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.FILLNARRATORS";
            cmd.CommandType = CommandType.StoredProcedure;
            OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
            cursorParam.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(cursorParam);
            cmd.ExecuteNonQuery();
            using (OracleDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    narratorNameCombo.Items.Add(reader.GetString(0));
                }
            }
        }

        public void TopicComboBox()
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.FILLTOPICS";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PNARRATORNAME", OracleDbType.Varchar2, 30).Value = narrator.ToUpper();
            OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
            cursorParam.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(cursorParam);
            cmd.ExecuteNonQuery();
            using (OracleDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    topicNameCombo.Items.Add(reader.GetString(0));
                }
            }
            con.Close();
        }

        public AddNewPodcast()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
            PodcastAdded += OnPodcastAdded;
        }

        private void OnPodcastAdded()
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                var homePage = Application.Current.Windows.OfType<Home>().FirstOrDefault();
                homePage?.LoadPodcasts();
            });
        }

        private void CloseBtn_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                using (OracleConnection con = new OracleConnection("DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=jokimi;DBA PRIVILEGE=SYSDBA"))
                {
                    con.Open();
                    using (OracleCommand cmd = con.CreateCommand())
                    {
                        try
                        {
                            cmd.CommandText = "ALTER SESSION SET \"_ORACLE_SCRIPT\" = TRUE";
                            cmd.CommandType = CommandType.Text;
                            cmd.ExecuteNonQuery();
                        }
                        catch (OracleException ex)
                        {
                            if (ex.Number == 1031)
                            {
                                MessageBox.Show("Недостаточно прав для выполнения ALTER SESSION.");
                            }
                            else
                            {
                                MessageBox.Show($"Ошибка при выполнении ALTER SESSION: {ex.Message}");
                            }
                        }
                    }
                    NarratorComboBox(con);
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show($"Ошибка при подключении к базе данных: {ex.Message}");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке окна: {ex.Message}");
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        private void AttachAudio_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                OpenFileDialog openFileDialog = new OpenFileDialog()
                {
                    Filter = "Audio Files|*.mp3;*"
                };
                if (openFileDialog.ShowDialog() == true)
                {
                    if (!openFileDialog.FileName.ToLower().EndsWith(".mp3"))
                    {
                        throw new Exception("Файл должен быть .mp3!");
                    }
                    audioName = openFileDialog.FileName;
                    audio = File.ReadAllBytes(openFileDialog.FileName);
                }
                openFileDialog = null;
                audioPath.Text = audioName;
            }
            catch (System.ArgumentException ae)
            {
                audioName = "";
                MessageBox.Show(ae.Message.ToString());
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message.ToString());
            }
        }

        private void NarratorNameCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            narratorNameCombo.IsEnabled = false;
            topicNameCombo.IsEnabled = true;
        }

        private void TopicNameCombo_DropDownOpened(object sender, EventArgs e)
        {
            narrator = narratorNameCombo.Text.Trim();
            topicNameCombo.Items.Clear();
            TopicComboBox();
        }

        private void AddBtn_Click(object sender, RoutedEventArgs e)
        {
            topic = topicNameCombo.Text.Trim();
            podcast = podcastName.Text.Trim();
            if (String.IsNullOrWhiteSpace(narrator) || String.IsNullOrWhiteSpace(topic) || String.IsNullOrWhiteSpace(podcast) || String.IsNullOrWhiteSpace(audioName))
            {
                MessageBox.Show("Заполните все поля!");
                return;
            }
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.ADDPODCAST";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PNARRATORNAME", OracleDbType.Varchar2, 30).Value = narrator;
            cmd.Parameters.Add("PTOPICNAME", OracleDbType.Varchar2, 30).Value = topic;
            cmd.Parameters.Add("PPODCASTNAME", OracleDbType.Varchar2, 30).Value = podcast;
            try
            {
                cmd.ExecuteNonQuery();
                con.Close();
                con.Open();
                OracleCommand cmd3 = con.CreateCommand();
                cmd3.CommandText = "SELECT * FROM SYS.narrator_topic_podcast_view WHERE upper(podcast_name) = upper('" + podcast + "') and upper(topic_name) = upper('" + topic + "') ORDER BY podcast_id ASC";
                cmd3.CommandType = CommandType.Text;
                OracleDataReader reader = cmd3.ExecuteReader();
                while (reader.Read())
                {
                    podcastId = reader.GetInt32(0);
                }
                con.Close();
                con.Open();
                FileStream fls;
                fls = new FileStream(audioName, FileMode.Open, FileAccess.Read);
                byte[] blob = new byte[fls.Length];
                fls.Read(blob, 0, System.Convert.ToInt32(fls.Length));
                fls.Close();
                if (audioName != "")
                {
                    OracleCommand cmd2 = con.CreateCommand();
                    OracleTransaction txn;
                    txn = con.BeginTransaction(IsolationLevel.ReadCommitted);
                    cmd2.Transaction = txn;
                    cmd2.CommandText = "UPDATE podcasts_t SET podcast_blob = :ImageFront WHERE podcast_id = :id";
                    cmd2.Parameters.Add(":ImageFront", OracleDbType.Blob);
                    cmd2.Parameters[":ImageFront"].Value = blob;
                    cmd2.Parameters.Add(":id", OracleDbType.Int16);
                    cmd2.Parameters[":id"].Value = podcastId;
                    cmd2.ExecuteNonQuery();
                    txn.Commit();
                    con.Close();
                    con.Dispose();
                    PodcastAdded?.Invoke();
                    MessageBox.Show("Подкаст добавлен успешно!");
                    this.Close();
                    Application.Current.Windows[0].Show();
                }
            }
            catch (Exception exc)
            {
                MessageBox.Show("Ошибка при добавлении подкаста!" + exc.Message);
            }
            con.Close();
        }

        private void TopicNameCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            topicNameCombo.IsEnabled = false;
            podcastName.IsReadOnly = false;
            attachAudio.IsEnabled = true;
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